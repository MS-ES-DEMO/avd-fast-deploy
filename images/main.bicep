targetScope = 'subscription'

// Global Parameters

@description('Azure region where resource would be deployed')
param location string
@description('Tags associated with all resources')
param tags object

// Resource Group Names

@description('Resource Groups names')
param resourceGroupNames object

var avdImagesResourceGroupName = resourceGroupNames.images


/* 
  AVD Images Resource Group deployment 
*/
resource avdImagesResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: avdImagesResourceGroupName
  location: location
  tags: tags
}

/* 
  Identity resources deployment 
*/

var imageBuilderIdentityName = 'imageBuilderIdentityAVD'
@description('Role definitions for Image Builder and Deployment Script entities')
param roleDefinitions object 
var deploymentScriptIdentityName = 'deploymentScriptAvdImage'
var imageBuilderRoleInfo = roleDefinitions.imageBuilderRole
var deploymentScriptRoleInfo = roleDefinitions.avdDeploymentScriptRole

module imageBuilderIdentityResources '../modules/Microsoft.Authorization/userAssignedIdentity.bicep' = {
  scope: avdImagesResourceGroup
  name: 'imageBuilderIdentityRss_Deploy'
  params: {
    name: imageBuilderIdentityName
    tags: tags
  }
}

module deploymentScriptIdentityResources '../modules/Microsoft.Authorization/userAssignedIdentity.bicep' = {
  scope: avdImagesResourceGroup
  name: 'deploymentScriptIdentityRss_Deploy'
  params: {
    name: deploymentScriptIdentityName
    tags: tags
  }
}

module imageBuilderRoleResources '../modules/Microsoft.Authorization/roleBeta.bicep' = {
  scope: avdImagesResourceGroup
  name: 'imageBuilderRoleRss_Deploy'
  params: {
    name: imageBuilderRoleInfo.name
    description: imageBuilderRoleInfo.description
    actions: imageBuilderRoleInfo.actions
    principalId: imageBuilderIdentityResources.outputs.principalId
  }
}

module deploymentScriptRoleResources '../modules/Microsoft.Authorization/roleBeta.bicep' = {
  scope: avdImagesResourceGroup
  name: 'deploymentScriptRoleRss_Deploy'
  params: {
    name: deploymentScriptRoleInfo.name
    description: deploymentScriptRoleInfo.description
    actions: deploymentScriptRoleInfo.actions
    principalId: deploymentScriptIdentityResources.outputs.principalId
  }
}

/* 
  Gallery resources deployment 
*/

param galleryProperties object
var galleryName = galleryProperties.name
//var gallerySoftDelete = galleryProperties.softDelete // It is in preview.

module galleryResources '../modules/Microsoft.Compute/gallery.bicep' = {
  scope: avdImagesResourceGroup
  name: 'galleryRss_Deploy'
  params: {
    name: galleryName
    tags: tags
    //softDelete: gallerySoftDelete
  }
}

/* 
  Image resources deployment 
*/

param imageDefinitionProperties object
var imageDefinitionName = imageDefinitionProperties.name

module imageResources '../modules/Microsoft.Compute/image.bicep' = {
  scope: avdImagesResourceGroup
  name: 'imageRss_Deploy'
  params: {
    name: imageDefinitionName
    tags: tags
    galleryName: galleryName
    imageDefinitionProperties: imageDefinitionProperties
  }
  dependsOn: [
    galleryResources
  ]
}

/*
Image Template resources deployment
*/


param imageTemplateProperties object

var imageTemplateName = imageTemplateProperties.name
var runOutputName = imageTemplateProperties.runOutputName
var artifactTags = imageTemplateProperties.artifactTags
var replicationRegions = imageTemplateProperties.replicationRegions 

module imageTemplateResources '../modules/Microsoft.VirtualMachineImages/imageTemplate.bicep' = {
  scope: avdImagesResourceGroup
  name: 'imageTemplateRss_Deploy'
  params: {
    name: imageTemplateName
    tags: tags
    imageBuilderIdentityName: imageBuilderIdentityName
    imageDefinitionName: imageDefinitionName
    runOutputName: runOutputName
    artifactsTags: artifactTags
    replicationRegions: replicationRegions    
  }
  dependsOn: [
    imageResources
  ]
}
