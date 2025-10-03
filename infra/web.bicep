param environmentName string
param location string = resourceGroup().location

param registryEndpoint string
param environmentId string
param identityId string
param imageName string 
param initImageName string

// The main Container App resource
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'web'
  tags: {'azd-env-name': environmentName, 'azd-service-name': 'web'}
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      // Ingress is required to access the app via HTTP
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
      registries: [
        {
          server: registryEndpoint
          identity: identityId
        }
      ]
    }
    template: {
      // Define a shared volume for the init and main container
      volumes: [
        {
          name: 'shared-data'
          storageType: 'EmptyDir'
        }
      ]
      // Define the init containers
      initContainers: [
        {
          name: 'my-init-container'
          image: initImageName
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          // Mount the shared volume
          volumeMounts: [
            {
              volumeName: 'shared-data'
              mountPath: '/shared'
            }
          ]
        }
      ]
      // Define the main application containers
      containers: [
        {
          name: 'my-main-app'
          image: imageName
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          // Mount the same shared volume
          volumeMounts: [
            {
              volumeName: 'shared-data'
              mountPath: '/shared'
            }
          ]
        }
      ]
    }
  }
}

