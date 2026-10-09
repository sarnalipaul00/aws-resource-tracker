# AWS Resource Tracker

A beginner Bash project that uses the AWS CLI to create a text report about selected AWS resources. It lists S3 buckets, EC2 instance IDs, Lambda functions, and IAM users. A Linux Cron job can run it on a schedule.

This is an inventory report. It does not calculate AWS costs, and it does not create, change, or delete AWS resources.

## What the project contains

```text
aws-resource-tracker/
├── aws-resource-tracker.sh   # Script that asks AWS for resource information
├── .gitignore                # Keeps generated reports and local files out of Git
└── README.md                 # Project instructions
```

When the script runs, it creates or replaces a file named `resourceTracker` in the current directory. The file is ignored by Git because it may contain information about your AWS account. The starter backup script is ignored too.

## Requirements

- Ubuntu/Linux or Windows Subsystem for Linux (WSL)
- Bash
- AWS CLI v2, configured to sign in to the AWS account you intend to inspect
- `jq`, used to select EC2 instance IDs from the AWS CLI JSON output
- AWS permissions to list the selected resources

You do not need to create any AWS resources to try the script. Empty sections can mean that no matching resources exist in the account or selected region.

Check the tools:

```bash
bash --version
aws --version
jq --version
```

Configure AWS authentication using a secure method supported by your account. Do not put access keys, passwords, or session tokens in this repository or in the script. Before running AWS commands, confirm that the CLI is signed in to the account you intend to use:

```bash
aws sts get-caller-identity
```

The script needs permission to list S3 buckets, describe EC2 instances, list Lambda functions, and list IAM users. EC2 and Lambda results depend on the AWS region configured in the CLI. S3 buckets and IAM users are account-level listings.

## Run the report

Open Ubuntu/WSL and go to the project folder. Use your actual folder path if it is different:

```bash
cd /mnt/c/Users/MANOSI/Documents/Codex/aws-resource-tracker
bash aws-resource-tracker.sh
```

Read the report:

```bash
cat resourceTracker
```

Each section begins with a heading. S3 output is a list, EC2 output contains instance IDs, and Lambda/IAM output is JSON from the AWS CLI. Do not publish the generated report; it may reveal account inventory or IAM usernames.

## Schedule it with Cron

Cron is a Linux scheduler. It starts the script at the time you specify. The script then makes the AWS CLI requests and writes the report. First, make sure the script works when you run it manually.

Open your schedule:

```bash
crontab -e
```

For example, this runs every day at 12:30 UTC:

```cron
30 12 * * * cd /mnt/c/Users/MANOSI/Documents/Codex/aws-resource-tracker && PATH=/home/manosi/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin bash ./aws-resource-tracker.sh >> /mnt/c/Users/MANOSI/Documents/Codex/aws-resource-tracker/cron.log 2>&1
```

The five time fields are minute, hour, day of month, month, and day of week. `30 12 * * *` means minute 30, hour 12, every day. Cron uses the Linux machine's timezone; check it with `date`. In WSL, Cron can only run while the WSL environment is running.

The `cd` makes sure the report is written in the project folder. The `PATH` lets Cron find AWS CLI and other system commands. The final part appends Cron messages to `cron.log`, which is ignored by Git. Keep any other Cron entries already in your schedule. Check the saved schedule with:

```bash
crontab -l
```

AWS sign-in sessions can expire. If the script works manually but Cron later reports an authentication error, sign in again using the AWS CLI method configured for your account, then inspect the log:

```bash
tail -n 30 /mnt/c/Users/MANOSI/Documents/Codex/aws-resource-tracker/cron.log
```

## Troubleshooting

- **`aws: command not found`:** Check that AWS CLI is installed and available in your terminal's `PATH`.
- **`jq: command not found`:** Install `jq` for your Linux/WSL distribution.
- **Access denied or expired sign-in:** Confirm the active AWS identity and that it has the required list permissions; sign in again if the session expired.
- **No EC2 instances or Lambda functions shown:** Check the configured AWS region and whether resources exist there.
- **Cron works differently from the terminal:** Check the full project path, Cron log, Linux timezone, WSL state, and AWS sign-in session.

## GitHub safety

The `.gitignore` file excludes `resourceTracker`, report/log folders, and the starter backup. Before committing, use `git status` to check which files will be included. Never commit AWS credentials, account-specific reports, or private configuration files.

## Resume description

After verifying the script and Cron schedule yourself, you could describe the project as:

> Built a Bash and AWS CLI script to report S3 buckets, EC2 instance IDs, Lambda functions, and IAM users; scheduled recurring report generation with Linux Cron.

Only claim the parts you personally ran and verified.
