# Terraform Commands Reference Guide

Danh sách các lệnh Terraform phổ biến và giải thích chi tiết.

---

## 1. Khởi tạo và Cấu hình

### `terraform init`
**Mục đích:** Khởi tạo thư mục làm việc Terraform  
**Chức năng:**
- Tải xuống các provider plugins (AWS, Azure, GCP, ...)
- Tải các modules từ remote sources (Git, S3, ...)
- Tạo file `.terraform/` và `.terraform.lock.hcl`
- Cấu hình backend (S3, local, ...)

**Khi nào dùng:**
- Lần đầu tiên clone project
- Sau khi thêm provider/module mới
- Sau khi thay đổi backend configuration

**Ví dụ:**
```bash
cd infra/
terraform init
```

---

### `terraform init -upgrade`
**Mục đích:** Nâng cấp provider plugins và modules lên phiên bản mới nhất  
**Chức năng:**
- Cập nhật `.terraform.lock.hcl` với version constraints mới
- Tải provider versions mới hơn nếu có

**Khi nào dùng:**
- Khi muốn update providers/modules
- Khi có cảnh báo về version cũ

---

### `terraform init -reconfigure`
**Mục đích:** Khởi tạo lại backend configuration  
**Chức năng:**
- Bỏ qua state hiện tại và cấu hình lại backend
- Dùng khi chuyển từ local backend sang remote (S3) hoặc ngược lại

**Khi nào dùng:**
- Chuyển đổi backend
- Fix lỗi backend configuration

---

## 2. Kiểm tra và Validate

### `terraform validate`
**Mục đích:** Kiểm tra cú pháp và cấu trúc của Terraform files  
**Chức năng:**
- Validate syntax của `.tf` files
- Kiểm tra references giữa resources
- Không cần AWS credentials
- Không kiểm tra logic business

**Khi nào dùng:**
- Trước khi commit code
- Trong CI/CD pipeline
- Sau khi chỉnh sửa code

**Ví dụ:**
```bash
terraform validate
# Output: Success! The configuration is valid.
```

---

### `terraform fmt`
**Mục đích:** Tự động format code theo chuẩn Terraform style  
**Chức năng:**
- Chỉnh sửa indentation, spacing
- Chuẩn hóa format của `.tf` files
- Có thể dùng `-check` để chỉ kiểm tra không sửa

**Khi nào dùng:**
- Trước khi commit (để code đẹp)
- Trong pre-commit hooks

**Ví dụ:**
```bash
terraform fmt              # Format tất cả files
terraform fmt -check       # Chỉ check, không sửa
terraform fmt -recursive   # Format cả subdirectories
terraform fmt -diff        # Xem diff trước khi format
```

---

### `terraform plan`
**Mục đích:** Tạo execution plan - xem những gì sẽ thay đổi  
**Chức năng:**
- So sánh state hiện tại với code mới
- Liệt kê resources sẽ được:
  - `+` (tạo mới)
  - `-` (xóa)
  - `~` (thay đổi)
  - `-/+` (thay thế - destroy rồi create)
- Không thực sự apply changes
- Cần AWS credentials và quyền đọc state

**Khi nào dùng:**
- Trước khi apply để review changes
- Trong CI/CD để preview
- Để estimate cost/resources

**Ví dụ:**
```bash
terraform plan                    # Plan đầy đủ
terraform plan -out=tfplan        # Lưu plan vào file
terraform plan -var="key=value"  # Pass variables
terraform plan -target=module.vpc # Plan chỉ module VPC
terraform plan -destroy          # Plan để destroy
```

**Output quan trọng:**
```
Plan: 5 to add, 2 to change, 1 to destroy.
```

---

### `terraform plan -detailed-exitcode`
**Mục đích:** Trả về exit code khác nhau để dùng trong scripts  
**Chức năng:**
- Exit code 0: No changes
- Exit code 1: Error
- Exit code 2: Có changes

**Khi nào dùng:**
- Trong CI/CD để detect có changes không
- Automation scripts

---

## 3. Triển khai và Áp dụng

### `terraform apply`
**Mục đích:** Thực sự tạo/sửa/xóa resources trên AWS  
**Chức năng:**
- Đọc plan và thực thi
- Tạo/modify/delete resources
- Cập nhật state file
- Yêu cầu confirmation (có thể bỏ qua với `-auto-approve`)

**⚠️ CẢNH BÁO:** Lệnh này sẽ thay đổi infrastructure thật!

**Khi nào dùng:**
- Sau khi review plan
- Deploy infrastructure mới
- Update existing resources

**Ví dụ:**
```bash
terraform apply                    # Interactive confirmation
terraform apply -auto-approve      # Không hỏi, apply luôn
terraform apply -var="key=value"  # Pass variables
terraform apply tfplan             # Apply từ saved plan
terraform apply -target=module.vpc # Apply chỉ module VPC
terraform apply -refresh=false     # Không refresh state trước
```

**Quy trình an toàn:**
```bash
terraform plan -out=tfplan    # 1. Tạo plan
terraform show tfplan         # 2. Review plan
terraform apply tfplan        # 3. Apply plan đã review
```

---

### `terraform apply -refresh-only`
**Mục đích:** Chỉ refresh state, không apply changes  
**Chức năng:**
- Đồng bộ state với infrastructure thực tế
- Phát hiện drift (resources bị thay đổi ngoài Terraform)
- Không tạo/sửa/xóa gì

**Khi nào dùng:**
- Sau khi resources bị thay đổi manual
- Để sync state với reality
- Trước khi plan để có state mới nhất

---

## 4. Xem và Quản lý State

### `terraform state list`
**Mục đích:** Liệt kê tất cả resources trong state  
**Chức năng:**
- Hiển thị danh sách resources đã được manage
- Format: `resource_type.resource_name` hoặc `module.module_name.resource_type.resource_name`

**Khi nào dùng:**
- Kiểm tra resources đã tạo
- Debug state issues
- Audit infrastructure

**Ví dụ:**
```bash
terraform state list
# Output:
# module.vpc.aws_vpc.main
# module.vpc.aws_subnet.public[0]
# module.eks.aws_eks_cluster.main
# module.db.aws_db_instance.acme
```

---

### `terraform state show <resource>`
**Mục đích:** Xem chi tiết một resource trong state  
**Chức năng:**
- Hiển thị đầy đủ attributes của resource
- Bao gồm cả sensitive data (cẩn thận!)

**Khi nào dùng:**
- Debug resource configuration
- Kiểm tra values
- Copy resource ID

**Ví dụ:**
```bash
terraform state show module.vpc.aws_vpc.main
terraform state show module.db.aws_db_instance.acme
```

---

### `terraform state pull`
**Mục đích:** Download state file về local (JSON format)  
**Chức năng:**
- Xuất state ra stdout dạng JSON
- Có thể redirect vào file để backup/analyze

**Khi nào dùng:**
- Backup state
- Analyze state structure
- Debug state issues

**Ví dụ:**
```bash
terraform state pull > state.json
terraform state pull | jq '.resources[] | .type'  # List resource types
```

---

### `terraform state push <file>`
**Mục đích:** Upload state file lên backend  
**Chức năng:**
- Đẩy state file local lên remote backend
- ⚠️ Nguy hiểm: có thể overwrite state của người khác

**Khi nào dùng:**
- Restore state từ backup
- Migrate state
- Chỉ dùng khi chắc chắn!

---

### `terraform state mv <source> <destination>`
**Mục đích:** Di chuyển resource trong state (rename)  
**Chức năng:**
- Đổi tên resource trong state
- Không destroy/create resource thật
- Dùng khi refactor code

**Khi nào dùng:**
- Rename resources trong code
- Move resources giữa modules
- Refactoring

**Ví dụ:**
```bash
terraform state mv aws_vpc.old aws_vpc.new
terraform state mv 'module.vpc.aws_subnet.public[0]' 'module.vpc.aws_subnet.public_new[0]'
```

---

### `terraform state rm <resource>`
**Mục đích:** Xóa resource khỏi state (không xóa resource thật)  
**Chức năng:**
- Remove resource khỏi Terraform management
- Resource vẫn tồn tại trên AWS
- Terraform sẽ không quản lý resource này nữa

**Khi nào dùng:**
- Import resources đã tồn tại
- Tách resources ra khỏi Terraform
- Cleanup state

**Ví dụ:**
```bash
terraform state rm module.db.aws_db_instance.acme
```

---

## 5. Import và Taint

### `terraform import <resource> <id>`
**Mục đích:** Import resource đã tồn tại vào Terraform state  
**Chức năng:**
- Thêm resource đã có trên AWS vào state
- Không tạo resource mới
- Cần viết code resource trước khi import

**Khi nào dùng:**
- Quản lý resources đã tạo manual
- Migrate từ CloudFormation/Console sang Terraform
- Recovery sau khi mất state

**Quy trình:**
```bash
# 1. Viết resource code trong .tf file
resource "aws_vpc" "main" {
  # ... config
}

# 2. Import resource
terraform import aws_vpc.main vpc-12345678

# 3. Chạy plan để sync code với state
terraform plan
```

**Ví dụ:**
```bash
terraform import aws_vpc.main vpc-0abc123def456
terraform import 'module.db.aws_db_instance.acme' acme-postgres
terraform import 'module.vpc.aws_subnet.public[0]' subnet-12345
```

---

### `terraform taint <resource>`
**Mục đích:** Đánh dấu resource cần được recreate  
**Chức năng:**
- Đánh dấu resource là "tainted"
- Lần apply tiếp theo sẽ destroy và recreate resource đó
- Dùng khi resource có vấn đề

**⚠️ LƯU Ý:** Resource sẽ bị destroy và tạo lại!

**Khi nào dùng:**
- Fix resource bị corrupted
- Force recreate để apply config mới
- Debug resource issues

**Ví dụ:**
```bash
terraform taint module.db.aws_db_instance.acme
terraform plan  # Sẽ thấy resource bị đánh dấu recreate
terraform apply
```

---

### `terraform untaint <resource>`
**Mục đích:** Bỏ đánh dấu taint  
**Chức năng:**
- Xóa taint flag
- Resource sẽ không bị recreate nữa

**Khi nào dùng:**
- Hủy taint nhầm
- Sau khi fix issue mà không cần recreate

---

## 6. Xóa và Hủy

### `terraform destroy`
**Mục đích:** Xóa tất cả resources được manage bởi Terraform  
**Chức năng:**
- Destroy tất cả resources trong state
- ⚠️ KHÔNG THỂ HOÀN TÁC!
- Yêu cầu confirmation

**Khi nào dùng:**
- Cleanup test environment
- Tear down infrastructure
- Chỉ khi chắc chắn muốn xóa hết!

**Ví dụ:**
```bash
terraform destroy                    # Interactive
terraform destroy -auto-approve      # Không hỏi
terraform destroy -target=module.vpc # Destroy chỉ module VPC
terraform destroy -var="key=value"   # Pass variables
```

**Quy trình an toàn:**
```bash
terraform plan -destroy -out=destroy.tfplan  # 1. Review
terraform show destroy.tfplan                # 2. Check
terraform apply destroy.tfplan               # 3. Destroy
```

---

### `terraform destroy -target=<resource>`
**Mục đích:** Chỉ destroy một resource/module cụ thể  
**Chức năng:**
- Selective destroy
- Hữu ích khi chỉ muốn xóa một phần

**Ví dụ:**
```bash
terraform destroy -target=module.db.aws_db_instance.acme
terraform destroy -target=module.vpc
```

---

## 7. Output và Show

### `terraform output`
**Mục đích:** Hiển thị tất cả output values  
**Chức năng:**
- In ra các giá trị đã define trong `outputs.tf`
- Có thể dùng trong scripts

**Khi nào dùng:**
- Lấy thông tin sau khi deploy
- Trong CI/CD pipelines
- Share thông tin với team

**Ví dụ:**
```bash
terraform output                    # Tất cả outputs
terraform output eks_cluster_name  # Một output cụ thể
terraform output -json              # JSON format
terraform output -raw eks_cluster_name  # Raw value (không quotes)
```

---

### `terraform show`
**Mục đích:** Hiển thị state hoặc plan file  
**Chức năng:**
- Format human-readable của state/plan
- Không cần AWS credentials

**Khi nào dùng:**
- Review saved plan
- Inspect current state
- Debug

**Ví dụ:**
```bash
terraform show              # Current state
terraform show tfplan      # Saved plan file
terraform show -json       # JSON format
```

---

## 8. Workspace (Environment Management)

### `terraform workspace list`
**Mục đích:** Liệt kê tất cả workspaces  
**Chức năng:**
- Hiển thị workspaces có sẵn
- Workspace mặc định là `default`

**Khi nào dùng:**
- Quản lý multiple environments (dev, staging, prod)
- Check current workspace

**Ví dụ:**
```bash
terraform workspace list
# Output:
#   default
# * dev
#   staging
#   prod
```

---

### `terraform workspace new <name>`
**Mục đích:** Tạo workspace mới  
**Chức năng:**
- Tạo workspace và switch sang nó
- Mỗi workspace có state riêng

**Khi nào dùng:**
- Setup environment mới
- Tách dev/staging/prod

**Ví dụ:**
```bash
terraform workspace new dev
terraform workspace new staging
```

---

### `terraform workspace select <name>`
**Mục đích:** Chuyển sang workspace khác  
**Chức năng:**
- Switch giữa các workspaces
- State sẽ thay đổi theo workspace

**Ví dụ:**
```bash
terraform workspace select dev
terraform workspace select prod
```

---

### `terraform workspace show`
**Mục đích:** Hiển thị workspace hiện tại  
**Chức năng:**
- In tên workspace đang active

**Ví dụ:**
```bash
terraform workspace show
# Output: dev
```

---

### `terraform workspace delete <name>`
**Mục đích:** Xóa workspace  
**Chức năng:**
- Xóa workspace và state của nó
- ⚠️ Không thể xóa workspace đang active

**Ví dụ:**
```bash
terraform workspace select default  # Switch trước
terraform workspace delete old_env
```

---

## 9. Graph và Visualization

### `terraform graph`
**Mục đích:** Tạo dependency graph  
**Chức năng:**
- Xuất graph dạng DOT format
- Có thể visualize bằng Graphviz

**Khi nào dùng:**
- Hiểu dependencies giữa resources
- Documentation
- Debug dependency issues

**Ví dụ:**
```bash
terraform graph > graph.dot
terraform graph | dot -Tsvg > graph.svg  # Cần cài Graphviz
terraform graph -type=plan                # Graph của plan
```

---

## 10. Lệnh Hữu ích Khác

### `terraform version`
**Mục đích:** Hiển thị version Terraform  
**Chức năng:**
- In version Terraform và provider versions

**Ví dụ:**
```bash
terraform version
# Output:
# Terraform v1.5.0
# on darwin_arm64
# + provider registry.terraform.io/hashicorp/aws v5.0.0
```

---

### `terraform providers`
**Mục đích:** Liệt kê providers đã cài  
**Chức năng:**
- Hiển thị providers và versions

**Ví dụ:**
```bash
terraform providers
```

---

### `terraform force-unlock <lock-id>`
**Mục đích:** Unlock state bị lock  
**Chức năng:**
- Xóa lock khi state bị stuck
- ⚠️ Chỉ dùng khi chắc chắn không có process nào đang chạy

**Khi nào dùng:**
- State bị lock do process bị kill
- Lock bị stuck

**Ví dụ:**
```bash
terraform force-unlock <lock-id>
```

---

## 11. Workflow Thông Dụng

### Workflow Cơ Bản (Lần đầu)
```bash
cd infra/
terraform init                    # 1. Khởi tạo
terraform validate                # 2. Validate code
terraform fmt                     # 3. Format code
terraform plan                    # 4. Xem plan
terraform apply                   # 5. Deploy
```

### Workflow Hàng Ngày
```bash
terraform init -upgrade           # Update providers
terraform validate               # Check syntax
terraform fmt                     # Format code
terraform plan -out=tfplan       # Tạo plan
terraform show tfplan            # Review plan
terraform apply tfplan           # Apply
```

### Workflow với Workspaces
```bash
terraform workspace select dev    # Switch environment
terraform plan
terraform apply
terraform output                  # Lấy thông tin
```

### Workflow Import Resource
```bash
# 1. Viết resource code
# 2. Import
terraform import aws_vpc.main vpc-12345
# 3. Sync
terraform plan
terraform apply
```

---

## 12. Best Practices

1. **Luôn chạy `terraform plan` trước `apply`**
2. **Dùng `-out` để save plan và review trước**
3. **Commit `.tf` files, không commit `.tfstate`**
4. **Dùng remote backend (S3) cho production**
5. **Dùng workspaces cho multiple environments**
6. **Validate và format code trước khi commit**
7. **Dùng `-target` cẩn thận, chỉ khi cần**
8. **Backup state thường xuyên**
9. **Dùng `terraform fmt` trong pre-commit hooks**
10. **Review plan kỹ trước khi apply**

---

## 13. Troubleshooting

### State bị lock
```bash
terraform force-unlock <lock-id>
```

### State out of sync
```bash
terraform refresh
terraform plan
```

### Resource bị drift
```bash
terraform plan -refresh-only
terraform apply -refresh-only
```

### Xóa resource khỏi state (không xóa trên AWS)
```bash
terraform state rm <resource>
```

### Import resource đã tồn tại
```bash
terraform import <resource> <id>
```

---

## Tóm Tắt Nhanh

| Lệnh | Mục đích |
|------|----------|
| `terraform init` | Khởi tạo project |
| `terraform validate` | Kiểm tra syntax |
| `terraform fmt` | Format code |
| `terraform plan` | Xem changes |
| `terraform apply` | Deploy infrastructure |
| `terraform destroy` | Xóa tất cả |
| `terraform state list` | Liệt kê resources |
| `terraform output` | Xem outputs |
| `terraform workspace` | Quản lý environments |
| `terraform import` | Import resources |

---

**Lưu ý:** Luôn đọc output của `terraform plan` kỹ trước khi apply!

