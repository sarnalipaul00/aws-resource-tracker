# AWS Resource Tracker

A learning project that uses Bash and the AWS CLI to create a dated, read-only inventory report for S3 buckets, EC2 instances, Lambda functions, and IAM users. A Linux Cron entry can run the script daily.

The report is an inventory snapshot. It does not calculate AWS charges or determine by itself whether a resource is safe to remove.

## Project layout

```text
aws-resource-tracker/
├── aws-resource-tracker.sh   # Bash script that gathers the inventory
├── .gitignore                # Keeps reports, logs, and local secrets out of Git
└── README.md                 # Setup, usage, scheduling, and security notes
```

The script creates a `reports/` directory beside itself when it runs. Generated reports are excluded from Git because they may contain account inventory and IAM usernames.

## Requirements

- A Linux shell (Ubuntu, another Linux distribution, or Windows Subsystem for Linux).
- Bash, AWS CLI v2, and an AWS account/profile with permission to list the resources.
- Network access to AWS APIs.

You do not need to create EC2 instances, buckets, or Lambda functions to practice this read-only inventory script. Results will be empty if the account has no matching resources in the selected region.

## 1. Install and check the tools

Install AWS CLI v2 by following the [official AWS installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). Bash is included with most Linux distributions and WSL.

```bash
bash --version
aws --version
```

## 2. Authenticate to AWS

Use the authentication method provided by your organization, training account, or AWS administrator. For AWS IAM Identity Center, configure a profile and sign in:

```bash
aws configure sso
aws sso login --profile YOUR_PROFILE
export AWS_PROFILE=YOUR_PROFILE
```

If your environment uses another approved credential method, follow its instructions instead. AWS recommends temporary credentials where available; do not place access keys in this repository or in the script. See the [AWS CLI authentication guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html).

Confirm which account and region the CLI will use before running the report:

```bash
aws sts get-caller-identity
aws configure get region
```

The script needs read permissions for the corresponding AWS operations: `sts:GetCallerIdentity`, `s3:ListAllMyBuckets`, `ec2:DescribeInstances`, `lambda:ListFunctions`, and `iam:ListUsers`. Ask an administrator to provide an appropriately limited role/profile; do not use root credentials.

## 3. Get the project and run it

From a terminal, enter the project folder. If you downloaded/cloned the repository, use the path where you saved it:

```bash
cd /path/to/aws-resource-tracker
chmod +x aws-resource-tracker.sh
./aws-resource-tracker.sh
```

The script prints the report path. Open the newest file in `reports/`:

```bash
ls -l reports/
cat reports/aws-resources-YYYY-MM-DD.txt
```

Replace `YYYY-MM-DD` with today's date shown by the `ls` output. You can also run with a different report folder:

```bash
REPORT_DIR="$HOME/aws-resource-reports" ./aws-resource-tracker.sh
```

## What the script does

1. Uses Bash's strict mode to stop on command errors and unset variables.
2. Finds its own folder so relative report paths work when Cron launches it.
3. Creates a dated report filename under `reports/`.
4. Calls AWS CLI read/list commands and prints headings for each service.
5. Writes to a temporary file first. If a query fails, the partial report is not installed as the final report.
6. Renames the finished temporary file to the dated report name.

EC2 and Lambda inventory is regional. Set the correct default region in the AWS profile or provide an AWS region using your normal CLI configuration. S3 bucket and IAM user listings are account-level.

## 4. Schedule the report with Cron

Cron is Linux's time-based scheduler. It launches the script; the script gathers AWS data and writes the report.

Find the full project path and check that the script runs manually first:

```bash
pwd
./aws-resource-tracker.sh
```

Edit the current Linux user's schedule:

```bash
crontab -e
```

Add this example to run every day at 6:00 PM. Replace the example profile and `/home/your-user/aws-resource-tracker` with your AWS profile name and actual full project path:

```cron
0 18 * * * AWS_PROFILE=YOUR_PROFILE /home/your-user/aws-resource-tracker/aws-resource-tracker.sh >> /home/your-user/aws-resource-tracker/cron.log 2>&1
```

Cron time uses the machine's local timezone. The five schedule fields are minute, hour, day of month, month, and day of week. `0 18 * * *` means minute 0, hour 18, every day/month/weekday. The rest of the line is the command to run. `>> ... 2>&1` appends standard output and error output to a log file.

Check the saved schedule with:

```bash
crontab -l
```

Cron runs as the user who owns that crontab. That user must be able to execute the script, write reports/logs, and authenticate to AWS at the scheduled time. Set `AWS_PROFILE=YOUR_PROFILE` on the Cron line (or configure the `default` profile) because shell exports from your terminal are not automatically inherited by Cron. Interactive sign-ins can expire, so check the Cron log and re-authenticate when needed. For dependable unattended use, use a properly scoped role and credential method supported by the host environment.

## 5. Troubleshooting

- **Access denied:** Confirm the active account/profile and ask for the required read-only permissions.
- **Wrong or empty EC2/Lambda results:** Check the configured region; those services are queried region by region.
- **Works manually but not in Cron:** Use absolute paths, inspect `cron.log`, verify the crontab user, and confirm that user's AWS authentication is still valid.
- **Report directory errors:** Check that the script's user can write beside the script, or set `REPORT_DIR` to a writable location.

## Security and publishing

- Never commit AWS access keys, session tokens, passwords, account-specific reports, or real IAM usernames.
- `.gitignore` excludes generated reports and logs. Review `git status` before every commit.
- Treat reports as sensitive operational data and limit local file access.
- Do not delete or stop a resource based on this inventory alone; verify its owner, workload, and cost data first.

## Add this project to GitHub

Create an empty repository on GitHub (for example, `aws-resource-tracker`). From this project directory:

```bash
git init -b main
git add README.md aws-resource-tracker.sh .gitignore
git status
git commit -m "Add AWS resource tracker"
git remote add origin https://github.com/YOUR-USERNAME/aws-resource-tracker.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username. Inspect `git status` before committing to ensure no report, log, or credential file is staged. GitHub's [official guide for pushing local code](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github) has more detail.

## Resume description

After you have implemented and run the project, you can describe it honestly as:

> Built a Bash and AWS CLI resource inventory tool for S3, EC2, Lambda, and IAM; generated dated reports and automated daily execution with Linux Cron.

Only list tools and results you personally verified. Do not claim cost savings unless you measured them.
