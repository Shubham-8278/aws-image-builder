# EC2 Image Builder Pipeline using CloudFormation

This project sets up an automated EC2 Image Builder pipeline using **AWS CloudFormation**. 

---

## 📦 Overview

This CloudFormation template automates the creation of a golden AMI using **EC2 Image Builder**. It supports:

- Custom base AMIs
- Cross-account AMI sharing
- Multiple architectures (x86_64 / ARM64)
- Tagging, logging, and version control

---

## 🛠️ Technologies Used

- **AWS CloudFormation**
- **EC2 Image Builder**
- **IAM Roles and Policies**
- **Amazon S3** (for storing scripts/components)
- **Amazon SNS** (optional for notifications)

---

## 🚀 Getting Started

### 1. Prerequisites

- AWS CLI configured
- Proper IAM permissions to deploy EC2 Image Builder resources
- S3 bucket for custom components

### 2. Uplaod the scripts to the S3 using the upload-to-s3.sh

 - configure the parameters in the upload-to-s3.sh 
    - S3_BUCKET="awsbucketforttn"
    - S3_PREFIX="imagebuilder/scripts"
    - LOCAL_SCRIPT_DIR="./scripts"
- These scripts will be used to create the custom component that we will create and apply on the golden image 
 **Making Changes - Adding More Scripts** 
    - The main.sh is used as the main script runner if you want to add more files add the files to the script folder and link them in the main.sh

### 3. Creating IAM Role


---

```yaml
# Description: AWS CloudFormation template for Amazon EC2 Image Builder pipeline with a web server component

Parameters:
  owner:
    Type: String
    Default: 'Shubham'

  ownerOrg:
    Type: String
    Default: 'TTN'

  environment:
    Type: String
    Default: 'POC'
    AllowedValues:
      - POC
      - dev
      - prod

Resources:

  # Instance Profile to attach to EC2 instances launched by Image Builder
  builderProfile0:
    Type: AWS::IAM::InstanceProfile
    DependsOn:
      - builderRole0
    Properties:
      Roles: 
        - !Ref builderRole0

  # IAM Role for EC2 Image Builder instances
  builderRole0:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service:
                - ec2.amazonaws.com  # Allows EC2 instances to assume this role
            Action:
              - 'sts:AssumeRole'

      ManagedPolicyArns: 
        - arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder  # Grants required Image Builder permissions
        - arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore       # Allows SSM access for automation
        - arn:aws:iam::aws:policy/AmazonS3FullAccess                 # Full S3 access (for scripts, logs, artifacts)

      Tags:
        - Key: owner
          Value: !Ref owner
        - Key: managed by
          Value: !Ref ownerOrg
        - Key: environment
          Value: !Ref environment

Outputs:
  InstanceProfile:
    Value: !Ref builderProfile0
    Export: 
      Name: !Sub '${AWS::StackName}-profile'
```

---

### 📚 References

- **[AWS::IAM::Role – CloudFormation Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-role.html)**
- **[AWS::IAM::InstanceProfile – CloudFormation Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-iam-instanceprofile.html)**
- **[IAM Policies for EC2 Image Builder](https://docs.aws.amazon.com/imagebuilder/latest/userguide/image-builder-permissions.html)**
- **[Best Practices for IAM Roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)**

---

### 4. Creating Security Group

---

```yaml
# Description: AWS CloudFormation template for Amazon EC2 Image Builder pipeline with a web server component

Parameters:
  vpcId:
    Type: AWS::EC2::VPC::Id  # Reference to existing VPC where the security group will be created

  owner:
    Type: String
    Default: "Shubham"

  ownerOrg:
    Type: String
    Default: "TTN"

  environment:
    Type: String
    Default: "POC"
    AllowedValues:
      - POC
      - dev
      - prod

Resources:

  # Security Group for EC2 Image Builder infrastructure
  builderSg0:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for ec2 image builder
      VpcId: !Ref vpcId  # Ensure the security group is associated with your chosen VPC

      # Add custom ingress/egress rules here if needed
      # SecurityGroupIngress:
      #   - IpProtocol: tcp
      #     FromPort: 80
      #     ToPort: 80
      #     CidrIp: 0.0.0.0/0

      Tags:
        - Key: owner
          Value: !Ref owner
        - Key: managed by
          Value: !Ref ownerOrg
        - Key: environment
          Value: !Ref environment

Outputs:
  builderSg0:
    Value: !Ref builderSg0
    Export: 
      Name: !Sub '${AWS::StackName}-builder'
```

---

### 📚 References

- **[AWS::EC2::SecurityGroup – CloudFormation Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group.html)**
- **[Amazon VPC Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)**
- **[Best Practices for Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html#SecurityGroupRules)**

---

---

## ✅ Pros of EC2 Image Builder (Detailed)

| Feature | Description |
|--------|-------------|
| ✅ **Fully Managed & Native AWS Service** | No need to install or manage additional tools. Works seamlessly with other AWS services like CloudWatch, SSM, IAM, and SNS. |
| ✅ **Secure and Compliant AMI Pipeline** | Enforces best practices via component validation, IAM control, and integrated logs. Supports AWS Inspector, Patch Manager, and more. |
| ✅ **Cross-Account AMI Sharing** | Out-of-the-box support for sharing AMIs across multiple AWS accounts using Image Builder distribution settings. |
| ✅ **Supports Scheduling & Versioning** | You can set daily/weekly/monthly build schedules. AMI versioning is automatic with easy rollback capabilities. |
| ✅ **Integrated with AWS Systems Manager (SSM)** | Reuse existing SSM documents or scripts as components, with centralized logging and inventory via SSM Agent. |
| ✅ **Reduced Human Error** | Declarative YAML/JSON-based definitions with CloudFormation/CDK support help reduce manual steps. |
| ✅ **Tighter Security** | Builder instances run temporarily in isolated environments with defined build lifecycles and auto-termination. |
| ✅ **Automatic Cleanup** | Temporary infrastructure (like EC2 builder instances) is automatically shut down post-build. No dangling resources. |
| ✅ **Cost-Efficient for Simple Workflows** | Pay only for the short-lived resources. No always-on servers required. |

---

## ❌ Cons of EC2 Image Builder (Detailed)

| Limitation | Description |
|------------|-------------|
| ❌ **Limited Customization** | Compared to Packer, it's harder to implement deeply customized workflows. You’re bound to the structure AWS provides (e.g., build/test/distribute stages). |
| ❌ **Slower Iteration Cycles** | Builds can take **10–30 minutes** for minor changes due to instance provisioning, testing, and distribution steps. |
| ❌ **No Local Debugging** | Unlike Packer, you can't test builds locally. You need to deploy to AWS to test even simple script updates. |
| ❌ **AWS-Only Ecosystem** | Image Builder is only for AWS. No multi-cloud/multi-provider support. If you're hybrid or multi-cloud, Packer is more flexible. |
| ❌ **Fewer Community Modules** | Unlike Packer's ecosystem (which has many ready-to-use modules), Image Builder relies on self-created components or basic SSM scripts. |
| ❌ **Approval Steps Require Extra Setup** | No built-in manual approval step (like CodePipeline). You’d need to build that separately using SNS + Lambda + approval logic. |
| ❌ **No Built-in CI/CD Integration** | Image Builder doesn’t natively integrate with GitHub/GitLab/Bitbucket. Requires external pipelines or triggering via CLI/API/CloudWatch Events. |
| ❌ **Output Visibility is Basic** | Logs are sent to CloudWatch Logs, but not as intuitive or visual as Packer's CLI output or GitHub Actions. No progress bar or step-by-step shell view. |

---

## 🧭 Typical EC2 Image Builder Workflow

1. **Define pipeline**  
   YAML or JSON via CloudFormation or UI. Includes source AMI, components, test phase, and distribution settings.

2. **Pipeline Trigger**  
   - Scheduled (e.g., nightly builds)
   - Manual trigger via AWS Console / CLI
   - Event-driven (e.g., via CloudWatch or Lambda)

3. **Image Build**  
   EC2 Image Builder launches a temporary EC2 instance → installs components → runs validation tests → creates AMI.

4. **Image Distribution**  
   Automatically shares the AMI across accounts or regions as configured. Supports naming and versioning.

5. **Cleanup**  
   Temporary build resources (EC2, volumes, etc.) are auto-deleted after completion.

---
