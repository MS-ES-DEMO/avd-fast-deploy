
param location string = resourceGroup().location
param tags object
param name string 

resource imageGallery 'Microsoft.Compute/galleries@2021-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    description: 'Gallery for images'
    softDeletePolicy: {
      isSoftDeleteEnabled: false
    }
  }
}
