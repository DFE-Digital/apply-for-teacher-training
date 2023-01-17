# DNS

Terraform code for managing Azure DNS Zones and records.

This is separated into two components

- zones
- records

This is becuase a zone will be created initially and then is unlikely to have changes made to it,
while records will be added or changed more frequently.

# Resource Group

Create the resource group, key vault and storage account to store the tfstate files:

`make apply domain-azure-resources AUTO_APPROVE=1`

# Zones

To create a new zone;

- Add JSON files

    - dns/zones/workspace_variables/${zone}-zone.tfvars.json
    - dns/zones/workspace_variables/backend_${zone}.tfvars

- Add the zone to the Makefile

- Run the make command (there is no workflow job for zone creation or update)

    - `make ${zone} dnszone-plan`
    - `make ${zone} dnszone-apply`

- Provide the NS records for delegation from education.gov.uk or service.gov.uk.

    - see https://www.gov.uk/service-manual/technology/get-a-domain-name#choose-where-youll-host-your-dns

Notes;

- Any zone updates would be made by making changes to the tfvars JSON file and running a "make ${zone} plan/apply"

Taking care that if this causes a zone creation the NS records may change and/or existing records may be deleted

- Some of our DNS zones have extra TXT and CAA records to protect against spoofing and invalid certificates, as per

    - see https://www.gov.uk/guidance/protect-domains-that-dont-send-email
    - see https://www.gov.uk/service-manual/technology/get-a-domain-name#set-up-security-certificates

If relevant we add the following 3 records to indicate we don't send mail from these domains, and use Amazon/DigiCert/GlobalSign/Azure (update as relevant) for certificates.

- TXT record (for SPF)
```
“v=spf1 -all”
```

- TXT record (for DMARC)
```
"v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk; ruf=mailto:dmarc-ruf@dmarc.service.gov.uk"
```

- CAA record
```
0 issue "digicert.com"
```

# Records

There is a JSON configuration file per env e.g. qa, staging, etc.

To create (or update) records in an existing zone:

- Add (or update) the relevant JSON file to:

    - dns/records/workspace_variables/${zone}-${env}.tfvars.JSON
    - dns/records/workspace_variables/backend_${zone}-${env}.tfvars (only on initial creation)

- Run the make command with DNS_ENV set to the environment you are adding records too

    - `make ${zone} dnsrecord-plan DNS_ENV=${env}`
    - `make ${zone} dnsrecord-apply DNS_ENV=$env}`
        - e.g. `make apply dnsrecord-plan DNS_ENV=qa`

Note;
- You should always check any changes via Terraform plan before applying to make sure you are not making unintended changes.
