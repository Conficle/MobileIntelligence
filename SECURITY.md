# Security Policy

## Supported Versions

The following table describes the versions of MobileIntelligence that currently receive security updates.

| Version | Supported |
| -------- | --------- |
| 0.1.x | ✅ |
| < 0.1.0 | ❌ |

Only the latest released version is actively maintained and receives security updates.

---

## Reporting a Vulnerability

If you believe you have discovered a security vulnerability in MobileIntelligence, please **do not create a public GitHub Issue**.

Instead, report the vulnerability privately by emailing to mobileintelligence187@gmail.com.

Please include the following information whenever possible:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- A proof of concept (if available)
- Suggested mitigation (optional)

Providing as much detail as possible helps us investigate and resolve the issue more quickly.

---

## Response Process

After receiving a security report, the maintainer will:

1. Acknowledge receipt of the report.
2. Investigate and validate the issue.
3. Assess the severity and potential impact.
4. Develop and test a fix.
5. Publish a security update if necessary.
6. Credit the reporter (if they wish to be acknowledged).

---

## Disclosure Policy

We follow a coordinated disclosure process.

Please allow reasonable time for the vulnerability to be investigated and resolved before publicly disclosing the issue.

Once a fix is available, a security advisory may be published describing:

- The affected versions
- The impact
- The mitigation
- The fixed version

---

## Scope

Examples of vulnerabilities that should be reported include:

- Authentication or authorization issues
- Sensitive data exposure
- Credential leakage
- Remote code execution
- Dependency vulnerabilities
- Injection attacks
- Cryptographic weaknesses
- Insecure network communication

Issues that are **not** generally considered security vulnerabilities include:

- Feature requests
- Performance issues
- Documentation improvements
- General coding bugs that do not have a security impact

---

## Security Best Practices

When using MobileIntelligence:

- Never hard-code API keys in source code.
- Store credentials securely using platform-provided secure storage (such as Keychain).
- Always use HTTPS when communicating with AI providers.
- Keep dependencies up to date.
- Follow your organization's security and compliance requirements.

---

Thank you for helping keep MobileIntelligence and its users secure.