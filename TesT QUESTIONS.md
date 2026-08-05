# Test Questions — Phase 3: Azure Enterprise Network

Twenty questions a technical interviewer might ask about this project, with model answers.

---

### Terraform Fundamentals

**1. What is Terraform, and why did you choose it over the Azure Portal or Azure CLI for this project?**
> Terraform is a declarative Infrastructure-as-Code tool: you describe the desired end state of your infrastructure in HCL, and Terraform determines the steps to reach that state. I chose it over manual portal work because it's repeatable, version-controlled, reviewable via pull requests, and self-documenting — the `.tf` files themselves describe exactly what infrastructure exists, which manual portal changes never do.

**2. Walk me through the standard Terraform workflow.**
> `terraform init` downloads the required providers and sets up the backend; `terraform validate` checks configuration syntax; `terraform fmt` normalizes formatting; `terraform plan` produces a dry-run of proposed changes; `terraform apply` executes that plan; `terraform destroy` tears down managed resources.

**3. What's the difference between `terraform plan` and `terraform apply`?**
> `plan` is read-only — it compares the current state against the desired configuration and shows exactly what would change, without making any changes. `apply` executes those changes against the real infrastructure (after confirmation, or automatically if given a saved plan file).

**4. What is a Terraform provider?**
> A plugin that translates HCL resource blocks into API calls against a specific platform — in this project, the `azurerm` provider translates my configuration into Azure Resource Manager API calls.

---

### Terraform State

**5. What is the Terraform state file, and why does it matter?**
> The state file (`terraform.tfstate`) maps the resources declared in configuration to real-world resource IDs. It's how Terraform knows what it's already created, detects drift, and calculates what a plan needs to change. Without it, Terraform would have no way to distinguish "create new" from "update existing."

**6. Why shouldn't you commit the state file to a public GitHub repository?**
> State files can contain sensitive data — sometimes including secrets or connection strings in plaintext — depending on the resources involved. They're also environment-specific and not meant to be shared or merged like code.

**7. What's the difference between local and remote state, and which would you use in production?**
> Local state stores `terraform.tfstate` on disk; remote state stores it in a shared backend (e.g., Azure Storage with state locking). Production teams almost always use remote state to enable collaboration, prevent concurrent modification, and keep state durable and backed up.

**8. What happens if two people run `terraform apply` at the same time without remote state locking?**
> Without locking, both could read stale state and write conflicting updates, potentially corrupting the state file or causing Terraform to attempt duplicate/conflicting resource operations. State locking (available with remote backends) prevents this by serializing applies.

---

### Dependencies & Resource Graph

**9. How does Terraform know the order to create resources in?**
> It builds a dependency graph from attribute references between resources. If Resource B references an attribute of Resource A, Terraform infers B depends on A and creates A first. Resources with no interdependency are created in parallel.

**10. What's the difference between implicit and explicit dependencies?**
> Implicit dependencies are inferred automatically from attribute references (e.g., a subnet referencing a VNet's name). Explicit dependencies are declared manually with `depends_on` when an operational dependency exists that isn't expressed through any attribute reference.

**11. In this project, why does the Network Interface depend on the NSG Association rather than just the Subnet directly?**
> To avoid a race condition — I wanted to guarantee the security rules were fully attached to the subnet before attaching a VM's NIC to it, rather than potentially exposing a brand-new NIC to a subnet with as-yet-unapplied security rules.

**12. What is a "computed attribute" in Terraform?**
> An attribute whose value isn't known until the resource is actually created by the provider — for example, a Public IP's assigned address, or any resource's `id`. During `plan`, these show as "known after apply."

---

### Azure Networking

**13. Why did you segment the network into three subnets instead of using one flat subnet?**
> Subnet segmentation lets me apply different, tier-appropriate security policies. The Web subnet needs to accept public HTTP/HTTPS traffic; the Database subnet should never be directly reachable from the internet. A single flat subnet would force one security policy across fundamentally different trust levels.

**14. What is a Network Security Group, and how does it differ from a firewall appliance?**
> An NSG is a stateless-per-rule, stateful-per-connection packet filter applied at the subnet or NIC level in Azure, evaluating inbound/outbound rules by priority. It's simpler and cheaper than a dedicated firewall appliance (like Azure Firewall) but doesn't offer deep packet inspection, threat intelligence, or centralized multi-VNet policy management.

**15. How does NSG rule priority work, and why does it matter?**
> Azure evaluates NSG rules in ascending numeric priority order and stops at the first matching rule. If a lower-priority-number `Deny` rule matches before an intended `Allow` rule, the `Allow` rule is never evaluated — so priority ordering has to be deliberate, not arbitrary.

**16. Why does the Database subnet only allow traffic from the Application subnet, not the Web subnet?**
> To enforce least-privilege network access consistent with a three-tier architecture: only the Application layer should ever query the database directly. This limits the blast radius if the Web tier is ever compromised — an attacker on the Web subnet still can't reach the database directly.

---

### Public IP, NIC & Compute

**17. What's the relationship between a Public IP, a NIC, and a VM in Azure?**
> A Public IP is a standalone Azure resource representing an internet-routable address. A Network Interface is the virtual NIC that attaches to a VM and can have that Public IP (plus a private IP from a subnet) associated with it. The VM itself doesn't hold networking configuration directly — it references the NIC, which holds the actual IP configuration.

**18. Your README says the VM wasn't successfully deployed. Walk me through what happened.**
> `terraform apply` succeeded for every resource up through the Network Interface, but failed on the VM resource with a `SkuNotAvailable` error from the Azure control plane — meaning the specific VM size wasn't available in that region at that time due to capacity constraints. I verified this wasn't a code issue: `terraform validate` and `plan` were both clean, and every upstream dependency provisioned correctly. The fix isn't a code change; it's picking an available region or SKU, or waiting for capacity, which I've documented as a next step.

**19. How would you prevent this kind of deployment failure in the future?**
> A few approaches: maintain a fallback list of acceptable VM SKUs and retry across them programmatically; design for multi-region deployment so a capacity issue in one region doesn't block the whole rollout; or check SKU availability proactively via the Azure CLI (`az vm list-skus`) before running `apply`.

---

### Infrastructure as Code / General

**20. What would you change about this project if you were deploying it for a real production workload?**
> Several things: move to remote state with locking, add a CI/CD pipeline running `fmt`/`validate`/`plan` on every pull request, replace the exposed public SSH endpoint with Azure Bastion, add static security scanning (`tfsec`/`checkov`), restructure the configuration into reusable modules, and apply Azure Policy for organization-wide guardrails. This project intentionally stays lean to focus on core networking and IaC concepts, but I'm aware of the gap between "lab-quality" and "production-quality" and treat that gap as the next phase of the series.
