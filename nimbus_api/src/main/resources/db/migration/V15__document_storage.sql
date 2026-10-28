-- Opaque storage key for uploaded driver/vehicle documents. The file
-- itself lives outside the web root; access is mediated by an authenticated
-- controller that checks document ownership.
ALTER TABLE driver_documents ADD COLUMN storage_key VARCHAR(255);
ALTER TABLE vehicle_documents ADD COLUMN storage_key VARCHAR(255);
