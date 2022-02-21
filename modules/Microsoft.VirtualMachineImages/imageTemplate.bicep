
param location string = resourceGroup().location
param tags object
param name string
param imageBuilderIdentityName string
param galleryName string
param imageDefinitionName string
param source object
param customize array
param runOutputName string
param replicationRegions array
param artifactsTags object

resource imageBuilderIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: imageBuilderIdentityName
}

resource gallery 'Microsoft.Compute/galleries@2020-09-30' existing = {
  name: galleryName
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2020-09-30' existing = {
  parent: gallery
  name: imageDefinitionName
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2021-10-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${imageBuilderIdentity.id}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 60
    vmProfile: {
      vmSize: 'Standard_D2_v3'
      osDiskSizeGB: 127
    }
    source: source
    customize: customize
    /*
    [
      {
        type: 'PowerShell'
        name: 'installFsLogix'
        runElevated: true
        runAsSystem: true
        scriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_WVD/0_installConfFsLogix.ps1'
      }
      {
        type: 'PowerShell'
        name: 'OptimizeOS'
        runElevated: true
        runAsSystem: true
        scriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_WVD/1_Optimize_OS_for_WVD.ps1'
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host \'restarting post Optimizations\''
        restartTimeout: '5m'
      }
      {
        type: 'PowerShell'
        name: 'Install Teams'
        runElevated: true
        runAsSystem: true
        scriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/14_Building_Images_WVD/2_installTeams.ps1'
      }
      {
        type: 'WindowsRestart'
        restartCheckCommand: 'write-host \'restarting post Teams Install\''
        restartTimeout: '5m'
      }
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
        updateLimit: 40
      }
    ]
    */
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: imageDefinition.id
        runOutputName: runOutputName
        artifactTags: artifactsTags
        replicationRegions: replicationRegions
      }
    ]
  }
}


