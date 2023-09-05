#Requires -Version 7.2
###################################
# FANCY CODE ######################
###################################
# DotSource From Function #########
###################################
# Author :  VCUDACHI              #
# License:  MIT                   #
# Created:  2023-0905@2112        #
# Version:  0.1                   #
###################################

Function Init-Runspace {
    . .\misc\DotsourceTest.ps1
    . .\misc\DotsourceTest.ps1
    . .\misc\DotsourceTest.ps1
    # ... #
    . .\misc\DotsourceTest.ps1
}

#Invoke DotSource in parent scope (hopefully Global)
Invoke-Command -ScriptBlock (Get-Item -Path Function:Init-Runspace | Select-Object -ExpandProperty ScriptBlock) -NoNewScope

#Test:
Get-PSCallStackProxy

###################
# $Source = [System.Management.Automation.Commandmetadata]::New((Get-Command Get-Item))
# [System.management.automation.proxycommand]::Create($Source)
###################