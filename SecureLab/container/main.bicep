param location string = 'eastus'
param containerName string = 'postgres'
param image string = 'postgres:latest'

var ghostsstorage = 'ghostsstoragedahall'
var ghostsstoragekey = 'w4Yz0FddE0SC1TP+7253gfnsKQz7nsclSmtsLwB5PlFGqPPHI9aF+FR2RS/uFS444NTysXTV6OtS+ASt9yhnuw=='
var dataVolumeName = 'dbdata'
var spectreDataVolumeName = 'spectredata'

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: containerName
  location: location
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: image
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
          volumeMounts: [
            {
              name: dataVolumeName
              mountPath: '/var/lib/postgresql/data'
            }
            {
              name: spectreDataVolumeName
              mountPath: '/tmp'
            }
          ]
          ports: [
            {
              port: 5432
            }
          ]
          command: [
            'pg_isready -U ghosts'
          ]
          environmentVariables: [
            {
              name: 'POSTGRES_DB'
              value: 'ghosts'
            }
            {
              name: 'POSTGRES_USER'
              value: 'ghosts'
            }
            {
              name: 'POSTGRES_PASSWORD'
              value: 'ghosts'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    volumes: [
      {
        name: dataVolumeName
        azureFile: {
          shareName: dataVolumeName
          storageAccountName: ghostsstorage
          storageAccountKey: ghostsstoragekey
        }
      }
      {
        name: spectreDataVolumeName
        azureFile: {
          shareName: spectreDataVolumeName
          storageAccountName: ghostsstorage
          storageAccountKey: ghostsstoragekey
        }
      }
    ]
  }
}
