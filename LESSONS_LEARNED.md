# Lessons Learned — Phase 3: Azure Enterprise Network

This document is a technical retrospective on the concepts, mechanics, and troubleshooting encountered while building this project.

---

## 1. Terraform References

Resources in Terraform become related to each other through **attribute references**, not through the order they're written in a file. For example, a subnet referencing `azurerm_virtual_network.main.name` tells Terraform two things simultaneously: what value to use, and that the subnet cannot be created before the VNet exists. This project relies almost entirely on implicit references to build its dependency chain, which keeps the code declarative rather than imperative — I describe *what* should exist and how resources relate, and Terraform determines *how* and *in what order* to create them.

## 2. Computed Attributes

Some resource attributes can't be known until Azure actually creates the resource — a Public IP's assigned address, a NIC's `private_ip_address`, or any resource's `id`. Terraform represents these as "known after apply" during `terraform plan`. This has practical implications: any output or downstream resource depending on a computed attribute implicitly waits for that resource to finish provisioning, and `terraform plan` output for such values is intentionally opaque until `apply` actually runs.

## 3. State Files

Terraform's state file (`terraform.tfstate`) is the single source of truth mapping configuration to real-world resources. Key takeaways:
- The state file must never be manually edited or committed to public version control (it can contain sensitive values).
- Losing the state file doesn't destroy real infrastructure, but it does break Terraform's ability to track and manage it — recovery requires `terraform import` on a per-resource basis.
- For any team or production context, **remote state** (e.g., an Azure Storage Account backend with state locking) is essential to prevent concurrent-apply conflicts. This project currently uses local state, which is documented as a [future improvement](../README.md#-future-improvements).

## 4. Resource Dependencies

Understanding the difference between **implicit** and **explicit** (`depends_on`) dependencies was one of the most valuable parts of this project. Implicit dependencies, created automatically through attribute references, should be preferred wherever possible because they keep the dependency graph accurate as the configuration evolves. `depends_on` was reserved for the rare case where a dependency exists operationally (e.g., avoiding a race condition between an NSG association and a NIC attachment) but isn't expressed through any direct attribute reference.

## 5. SSH Keys

The Linux VM is configured for SSH key-based authentication rather than password authentication, consistent with Azure and general security best practice. Lessons here included:
- Never committing private keys to the repository (`.gitignore` explicitly excludes `*.pem` and any `id_rsa*` files).
- Referencing only the **public** key in `compute.tf`, sourced from a variable or a file path outside version control.
- Understanding that disabling password authentication on the VM (`disable_password_authentication = true`) is a security requirement enforced at the resource level, not just a convention.

## 6. Azure Networking Concepts

- **Address space planning**: allocating non-overlapping CIDR blocks per subnet (Web, Application, Database) to avoid future peering conflicts.
- **Tier isolation**: Network Security Groups enforce that only the necessary traffic can move between tiers (e.g., only the Application subnet can reach the Database subnet on port 1433 — the Web subnet cannot reach the database directly).
- **NSG rule priority**: Azure evaluates NSG rules in ascending priority order and stops at the first match, which required careful priority numbering to avoid an unintended `Deny` rule shadowing an intended `Allow` rule.

## 7. Azure Deployment Troubleshooting

Working through a real deployment failure (rather than a purely "green path" tutorial) was the most instructive part of this project. It reinforced a habit of reading Azure error messages closely — distinguishing errors that originate from Terraform's configuration parsing versus errors returned by the **Azure Resource Manager control plane** after Terraform has already submitted a valid request.

## 8. Azure Regional Capacity Limitations

The Linux VM failed to provision with a `SkuNotAvailable` error. This is an **Azure-side capacity constraint**, not a Terraform or configuration issue:

- Azure regions have finite hardware capacity per VM SKU family.
- High-demand periods or high-demand regions can temporarily exhaust available capacity for specific SKUs, independent of subscription quota.
- This is a well-documented, common occurrence in Azure — not unique to this project or account.

**How I confirmed the code, not the capacity, was the variable:**
1. `terraform validate` — passed with zero errors.
2. `terraform plan` — produced a complete, accurate plan for the VM resource with all attributes correctly resolved.
3. All upstream resources (Public IP, NIC, subnet, NSG association) deployed successfully — proving the network and security layers of the configuration were sound.
4. The failure occurred specifically inside the Azure control plane's SKU allocation step, evidenced by the `SkuNotAvailable` error code returned directly from the `compute.VirtualMachinesClient`.

**Documented resolution paths** (for future re-attempt):
- Redeploy to an alternate region with available capacity for the target SKU.
- Select a different VM size/series available in the current region.
- Open an Azure support request for a capacity/quota increase.
- Retry later, since regional capacity is not static.

This is also a realistic preview of how production teams design around capacity risk: multi-region deployment strategies, SKU flexibility lists, and automated retry/failover logic are common patterns specifically because of constraints like this one.

## 9. Best Practices Reinforced

- Split configuration by concern (`network.tf`, `security.tf`, `compute.tf`) rather than one monolithic file.
- Use variables for anything environment-specific; never hardcode region, address space, or SKU directly into resource blocks.
- Run `terraform fmt` and `terraform validate` before every `plan`.
- Document infrastructure failures transparently — a clean, honest failure writeup is more credible to a technical reviewer than an artificially "perfect" project.
- Treat `.gitignore` as a security control, not a formality (state files, `.tfvars` with secrets, and SSH keys should never reach version control).
