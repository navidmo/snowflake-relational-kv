-- ========================================
-- Tag Definitions (required before usage)
-- ========================================

CREATE OR REPLACE TAG data_sensitivity STRING COMMENT = 'Data classification level';

-- ========================================
-- Supporting Lookup Tables
-- ========================================

-- Role-based tenant isolation
CREATE OR REPLACE TABLE tenant_access_control (
    tenant_id NUMBER,
    role_name STRING
);

-- Sample data
INSERT INTO tenant_access_control (tenant_id, role_name) VALUES
(101, 'ANALYST_TENANT_101'),
(101, 'DATA_ENGINEER'),
(102, 'ANALYST_TENANT_102'),
(102, 'COMPLIANCE_OFFICER');

-- Attributes considered sensitive (used in masking policy)
CREATE OR REPLACE TABLE sensitive_attributes (
    attribute_id NUMBER
);

-- Sample data (attribute IDs must match IDs in `attributes` table)
INSERT INTO sensitive_attributes VALUES (1), (2), (3);

-- ========================================
-- Core Schema for EAV Model
-- ========================================

CREATE OR REPLACE TABLE attributes (
    attribute_id NUMBER AUTOINCREMENT PRIMARY KEY,
    name STRING NOT NULL,
    data_type STRING NOT NULL CHECK (data_type IN ('STRING', 'NUMBER', 'BOOLEAN', 'DATE', 'OBJECT', 'ARRAY')),
    attribute_group STRING,
    is_required BOOLEAN DEFAULT FALSE,
    version INTEGER DEFAULT 1,
    schema_definition OBJECT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE attribute_values (
    value_id NUMBER AUTOINCREMENT PRIMARY KEY,
    entity_id NUMBER NOT NULL,
    attribute_id NUMBER NOT NULL,
    value VARIANT,
    tenant_id NUMBER NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (attribute_id) REFERENCES attributes(attribute_id)
);

CREATE OR REPLACE TABLE attribute_value_history (
    history_id NUMBER AUTOINCREMENT PRIMARY KEY,
    value_id NUMBER NOT NULL,
    entity_id NUMBER NOT NULL,
    attribute_id NUMBER NOT NULL,
    old_value VARIANT,
    new_value VARIANT,
    changed_by STRING,
    changed_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (attribute_id) REFERENCES attributes(attribute_id)
);

-- ========================================
-- View for Analytical Querying
-- ========================================

CREATE OR REPLACE VIEW vw_attribute_values AS
SELECT 
    av.entity_id,
    a.name AS attribute_name,
    a.attribute_group,
    a.data_type,
    a.version,
    av.value,
    av.created_at,
    av.updated_at
FROM attribute_values av
JOIN attributes a ON av.attribute_id = a.attribute_id;

-- ========================================
-- Performance Optimizations
-- ========================================

ALTER TABLE attribute_values 
    CLUSTER BY (entity_id, attribute_id);

ALTER TABLE attribute_value_history 
    CLUSTER BY (entity_id, changed_at);

-- ========================================
-- Governance Hooks and Policies
-- ========================================

-- Row access policy for tenant isolation
CREATE OR REPLACE ROW ACCESS POLICY eav_row_policy
AS (tenant_id_column NUMBER) 
RETURNS BOOLEAN ->
    EXISTS (
        SELECT 1 FROM tenant_access_control 
        WHERE tenant_id = tenant_id_column 
        AND CURRENT_ROLE() = role_name
    );

ALTER TABLE attribute_values 
    ADD ROW ACCESS POLICY eav_row_policy 
    ON (tenant_id);

-- Masking policy using lookup table (Snowflake compliant)
CREATE OR REPLACE MASKING POLICY mask_sensitive_values
AS (val VARIANT, attr_id NUMBER) 
RETURNS VARIANT ->
    CASE
        WHEN EXISTS (
            SELECT 1 FROM sensitive_attributes 
            WHERE attribute_id = attr_id
        )
        AND CURRENT_ROLE() NOT IN ('DATA_ENGINEER', 'COMPLIANCE_OFFICER')
        THEN '***REDACTED***'
        ELSE val
    END;

ALTER TABLE attribute_values 
    MODIFY COLUMN value 
    SET MASKING POLICY mask_sensitive_values 
    USING (value, attribute_id);

-- ========================================
-- Metadata Tagging (for Cataloging/Classification)
-- ========================================

ALTER TABLE attribute_values 
    SET TAG data_sensitivity = 'PII';

ALTER TABLE attribute_value_history 
    SET TAG data_sensitivity = 'PII_AUDIT';

-- ========================================
-- Secure View for Controlled Access
-- ========================================

CREATE OR REPLACE SECURE VIEW public.vw_safe_attributes AS
SELECT 
    av.entity_id,
    a.name AS attribute_name,
    av.value
FROM attribute_values av
JOIN attributes a ON av.attribute_id = a.attribute_id
WHERE a.data_type NOT IN ('OBJECT', 'ARRAY');

-- ========================================
-- Optional Logging/Auditing via External Functions
-- ========================================

-- API Integration must be created by account admin
-- CREATE OR REPLACE API INTEGRATION audit_log_integration
--   API_PROVIDER = aws_api_gateway
--   ENABLED = TRUE
--   API_AWS_ROLE_ARN = 'arn:aws:iam::<account>:role/snowflake_audit_logger'
--   API_ALLOWED_PREFIXES = ('https://<your-gateway>.execute-api.us-east-1.amazonaws.com/prod/')
--   COMMENT = 'Audit integration for attribute-level logging';

CREATE OR REPLACE EXTERNAL FUNCTION log_audit_event(
    event_type STRING,
    table_name STRING,
    entity_id NUMBER,
    attribute_id NUMBER,
    user_name STRING,
    timestamp TIMESTAMP_NTZ
)
RETURNS STRING
API_INTEGRATION = audit_log_integration
HEADERS = ( 'x-api-key' = '<your_api_key>' )
URL = 'https://<your-gateway>.execute-api.us-east-1.amazonaws.com/prod/log_event';

-- Example usage:
-- SELECT log_audit_event('ATTRIBUTE_UPDATED', 'attribute_values', 123, 456, CURRENT_USER(), CURRENT_TIMESTAMP());
