# Get the last run result of your specific task
$taskName = "Weekly Azure SQL Backup"  # Replace with your exact task name
$taskPath = "\"  # Use the path where your task is stored (usually root "\")

$task = Get-ScheduledTask -TaskName $taskName -TaskPath $taskPath
$taskInfo = Get-ScheduledTaskInfo -TaskName $taskName -TaskPath $taskPath

Write-Host "Task Name: $($task.TaskName)"
Write-Host "Last Run Time: $($taskInfo.LastRunTime)"
Write-Host "Last Result: $($taskInfo.LastTaskResult)"
Write-Host "Next Run Time: $($taskInfo.NextRunTime)"

# Interpret the result code
if ($taskInfo.LastTaskResult -eq 0) {
    Write-Host "Status: Task completed successfully" -ForegroundColor Green
} elseif ($taskInfo.LastTaskResult -eq 267009) {
    Write-Host "Status: Task is still running" -ForegroundColor Yellow
} elseif ($taskInfo.LastTaskResult -eq 267014) {
    Write-Host "Status: Task has not yet run" -ForegroundColor Yellow
} else {
    Write-Host "Status: Task failed with error code $($taskInfo.LastTaskResult)" -ForegroundColor Red
}

# Get detailed history (last 5 runs)
Write-Host "`nDetailed Task History (Last 5 runs):"
Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-TaskScheduler/Operational'
    ID = 100, 102, 103, 129, 200, 201  # Task started, completed, or failed events
} -MaxEvents 20 | Where-Object { $_.Message -like "*$taskName*" } | 
Select-Object -First 5 | 
Format-Table TimeCreated, ID, Message -AutoSize