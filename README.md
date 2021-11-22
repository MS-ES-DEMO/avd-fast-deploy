# avd-consumption-play

This repository contains the templates required to deploy a Virtual Desktop scenario useful for demo purposes. 

## Repository files

The `avd` folder structure is as follow:

- `environment`: deploys hostpool (pooled or personal) resources, scaling plan, desktop application group, remoteapp application group (only for pooled hostpool) and a workspace.

- `addHost`: deploys the required modules to add new session hosts to the hostpool deployed.

- `iam`: deploys virtual desktop autoscale role resources.

## Prerequisites

* [Install the latest version of PowerShell available for your operating system](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.2). Powershell 7.0 is the minimum required version to run this script.

* [Azure CLI version 2.20.0 or later installed is also required](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest). Use the below command to check your current installed version.

``` shell
az --version
```

* Install Bicep CLI running the bellow command.

``` shell
az bicep install
```

## How to deploy

### Environment requirements

#### Option 1
Deploy https://github.com/MS-ES-DEMO/vwan-azfw-consumption-play repository. It will create a Hub and Spoke network topology and some others resources required to deploy this virtual desktop scenario quickly.

#### Option 2

It will be necessary some resources:
- A monitoring Resource Group 
- A log Analytics workspace created in the monitoring Resource Group
- A network Resource Group
- A vnet for virtual desktop workloads created in the network Resource Group
- A subnet for the hostpool 
- An Active Directory Domain Services or Azure Active Directory Domain Services connectivity

### Steps

* Clone this repo:

``` shell   
git clone https://github.com/MS-ES-DEMO/avd-consumption-play.git
```

* Create a folder called "Tools" under the `C:\Program Files\PowerShell\7\Modules` path and copy the `RandomPassword.psm1` file into this folder. This powershell module will be use by `deploy.ps1` to generate strong passwords for two important required parameters.

* Select and edit the parameter file based on whether you will deploy personal or pooled host pool.

* Login to AZ CLI using the `az login` command.

* Edit the `--parameters` attribute in the `deploy.ps1` script with the correct parameter file name and then run the `deploy.ps1` script.



