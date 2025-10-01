@description('The location for all resources.')
param location string = resourceGroup().location

// Parameters to receive the container images built by azd.
// The names MUST match the 'image' properties from azure.yaml, with dots replaced by underscores.
@description('The image for the main application container.')
param my_init_container_app_my_app string

@description('The image for the init container.')
param my_init_container_app_init_app string

// A Log Analytics workspace is required for the Container App Environment.
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// The Container App Environment where all apps will be deployed.
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: 'cae-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// The main Container App resource
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-${uniqueString(resourceGroup().id)}'
  tags: {'azd-service-name': 'web'}
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      // Ingress is required to access the app via HTTP
      ingress: {
        external: true
        targetPort: 8080
        transport: 'http'
      }
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
          image: my_init_container_app_init_app
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
          image: my_init_container_app_my_app
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

// Output the URL of the deployed application
@description('The URL of the deployed application.')
output appUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
