# Azure ALZ Platform Automation

This repository provides Infrastructure as Code (IaC) templates and automation scripts for deploying Azure Landing Zones (ALZ) platform components using tools like Bicep, Terraform, and GitHub Actions. It focuses on automating the platform landing zone, including management groups, connectivity, identity, and governance, aligned with the Microsoft Cloud Adoption Framework (CAF).

The setup is designed for step-by-step building, starting from bootstrapping and progressing through customization. This ensures a scalable, secure foundation for AI and other workloads.

## Overview

Azure Landing Zones provide a modular architecture for organizing Azure resources at scale. This repo automates the platform zone deployment, drawing from official Microsoft guidance. Key features include:

- Modular Bicep or Terraform templates for core components (e.g., management groups, networking hubs).
- GitHub Actions workflows for CI/CD pipelines with secure authentication via OpenID Connect (OIDC).
- Integration with Azure services like Microsoft Entra ID, Azure Policy, and Monitor.
- Support for multi-tenant and high-availability configurations.

For more on ALZ concepts, see the [Azure Landing Zones documentation](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/).

## Prerequisites

Before starting:
- An active Azure subscription with Owner permissions at the tenant root.
- A Microsoft Entra ID tenant.
- GitHub account and repository access.
- Installed tools: Azure CLI, PowerShell, Bicep CLI (or Terraform), and Git.
- Familiarity with IaC principles; review [Infrastructure as Code best practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/considerations/infrastructure-as-code).

Install the ALZ PowerShell module: `Install-Module -Name ALZ`.

## Getting Started

1. **Clone the Repository**:  
   `git clone https://github.com/your-org/azure-alz-platform-automation.git`  
   Navigate to the repo: `cd azure-alz-platform-automation`.

2. **Bootstrap the Environment**:  
   Use the ALZ accelerator to set up GitHub workflows and Azure resources. Run the PowerShell module with your inputs (e.g., subscription ID, GitHub org).

3. **Customize and Deploy**:  
   Edit Bicep/Terraform files for your topology. Trigger deployments via GitHub Actions.

Detailed steps will be built incrementally. Confirm each step before proceeding.

## Deployment Flow

Follow the [ALZ Deployment Flow](https://github.com/Azure/ALZ-Bicep/wiki/DeploymentFlow) for sequence: Management groups first, then policies, networking, etc.

## Contributing

Contributions are welcome! Review the [Contributing guide](CONTRIBUTING.md) (create if needed). Submit pull requests for enhancements. Agree to the Microsoft Contributor License Agreement (CLA) upon PR submission.

This project follows the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).

## Telemetry

Deployments may send usage data to Microsoft for product improvement, governed by [Microsoft's privacy policies](https://www.microsoft.com/trustcenter). Opt out via configuration if desired.

## Security

Report vulnerabilities following [Security guidelines](SECURITY.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Trademarks

Use of Microsoft trademarks must follow [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).