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

param galleryProperties object
var galleryName = galleryProperties.name
var gallerySoftDelete = galleryProperties.softDelete // It is in preview.

param imageDefinitionProperties object
var imageDefinitionName = imageDefinitionProperties.name

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

param imageBuilderIdentityName string
param imageBuilderRoleInfo object 
param deploymentScriptIdentityName string
param deploymentScriptRoleInfo object 

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
    principalId: imageBuilderRoleInfo.principalId
  }
}

module deploymentScriptRoleResources '../modules/Microsoft.Authorization/roleBeta.bicep' = {
  scope: avdImagesResourceGroup
  name: 'deploymentScriptRoleRss_Deploy'
  params: {
    name: deploymentScriptRoleInfo.name
    description: deploymentScriptRoleInfo.description
    actions: deploymentScriptRoleInfo.actions
    principalId: deploymentScriptRoleInfo.principalId
  }
}

/* 
  Gallery resources deployment 
*/

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
