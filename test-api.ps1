# Banking API Test Script for PowerShell
# Make sure the Spring Boot application is running on port 8080

$BaseUrl = "http://localhost:8080/api/bank"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Banking API Test Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Register User 1
Write-Host "1. Registering User 1 (John Doe)..." -ForegroundColor Yellow
$user1Response = Invoke-RestMethod -Uri "$BaseUrl/register?name=John Doe&email=john@example.com" -Method Post
Write-Host "Response: $($user1Response | ConvertTo-Json)" -ForegroundColor Green
Write-Host ""

# 2. Register User 2
Write-Host "2. Registering User 2 (Jane Smith)..." -ForegroundColor Yellow
$user2Response = Invoke-RestMethod -Uri "$BaseUrl/register?name=Jane Smith&email=jane@example.com" -Method Post
Write-Host "Response: $($user2Response | ConvertTo-Json)" -ForegroundColor Green
Write-Host ""

# Accounts are created automatically when users are registered
# Account IDs are auto-generated sequentially (1, 2, etc.)
$account1Id = 1
$account2Id = 2
Write-Host "Using Account IDs: Account1=$account1Id, Account2=$account2Id" -ForegroundColor Cyan
Write-Host ""

# 3. Check Account 1 (should be 0.0)
Write-Host "3. Checking Account 1 balance..." -ForegroundColor Yellow
$account1 = Invoke-RestMethod -Uri "$BaseUrl/account/$account1Id" -Method Get
Write-Host ($account1 | ConvertTo-Json) -ForegroundColor Green
Write-Host ""

# 4. Deposit to Account 1
Write-Host "4. Depositing 1000 to Account 1..." -ForegroundColor Yellow
$account1 = Invoke-RestMethod -Uri "$BaseUrl/deposit/$account1Id?amount=1000" -Method Post
Write-Host ($account1 | ConvertTo-Json) -ForegroundColor Green
Write-Host ""

# 5. Check Account 1 balance again
Write-Host "5. Checking Account 1 balance after deposit..." -ForegroundColor Yellow
$account1 = Invoke-RestMethod -Uri "$BaseUrl/account/$account1Id" -Method Get
Write-Host ($account1 | ConvertTo-Json) -ForegroundColor Green
Write-Host ""

# 6. Withdraw from Account 1
Write-Host "6. Withdrawing 300 from Account 1..." -ForegroundColor Yellow
$account1 = Invoke-RestMethod -Uri "$BaseUrl/withdraw/$account1Id?amount=300" -Method Post
Write-Host ($account1 | ConvertTo-Json) -ForegroundColor Green
Write-Host ""

# 7. Check Account 1 balance after withdrawal
Write-Host "7. Checking Account 1 balance after withdrawal..." -ForegroundColor Yellow
$account1 = Invoke-RestMethod -Uri "$BaseUrl/account/$account1Id" -Method Get
Write-Host ($account1 | ConvertTo-Json) -ForegroundColor Green
Write-Host ""

# 8. Transfer from Account 1 to Account 2
Write-Host "8. Transferring 200 from Account 1 to Account 2..." -ForegroundColor Yellow
$transferResult = Invoke-RestMethod -Uri "$BaseUrl/transfer?from=$account1Id&to=$account2Id&amount=200" -Method Post
Write-Host $transferResult -ForegroundColor Green
Write-Host ""

# 9. Check both accounts after transfer
Write-Host "9. Checking Account 1 balance after transfer..." -ForegroundColor Yellow
$account1 = Invoke-RestMethod -Uri "$BaseUrl/account/$account1Id" -Method Get
Write-Host ($account1 | ConvertTo-Json) -ForegroundColor Green
Write-Host ""
Write-Host "10. Checking Account 2 balance after transfer..." -ForegroundColor Yellow
$account2 = Invoke-RestMethod -Uri "$BaseUrl/account/$account2Id" -Method Get
Write-Host ($account2 | ConvertTo-Json) -ForegroundColor Green
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Test Complete!" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

