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
var gallerySoftDelete = galleryProperties.softDelete

param imageDefinitionProperties object

/* 
  AVD Images Resource Group deployment 
*/
resource avdImagesResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: avdImagesResourceGroupName
  location: location
  tags: tags
}


/* 
  Gallery resources deployment 
*/

module galleryResources '../modules/Microsoft.Compute/gallery.bicep' = {
  scope: avdImagesResourceGroup
  name: 'galleryRss_Deploy'
  params: {
    name: galleryName
    softDelete: gallerySoftDelete
    tags: tags
  }
}

/* 
  Image resources deployment 
*/

module imageResources '../modules/Microsoft.Compute/image.bicep' = {
  scope: avdImagesResourceGroup
  name: 'imageRss_Deploy'
  params: {
    name: imageDefinitionProperties.name
    tags: tags
    imageDefinitionProperties: imageDefinitionProperties
  }
}
