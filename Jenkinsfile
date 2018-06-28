podTemplate(label: 'buildpod',
    volumes: [
        hostPathVolume(hostPath: '/etc/docker/certs.d', mountPath: '/etc/docker/certs.d'),
        hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
        secretVolume(secretName: 'registry-account', mountPath: '/var/run/secrets/registry-account'),
        configMapVolume(configMapName: 'registry-config', mountPath: '/var/run/configs/registry-config')
    ],
    containers: [
        containerTemplate(name: 'docker', image: 'mycluster.icp:8500/default/docker:latest', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'containertest', image: 'mycluster.icp:8500/default/containertest:latest', command: 'cat', ttyEnabled: true),
        containerTemplate(name: 'helm', image: 'mycluster.icp:8500/default/k8s-helm:latest', command: 'cat', ttyEnabled: true)
  ]) {

    node('buildpod') {
        checkout scm
        container('docker') {
            stage('Build Docker Image') {
                sh """
                #!/bin/bash
                #NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                #REGISTRY=`cat /var/run/configs/registry-config/registry`
                NAMESPACE=default
                REGISTRY=mycluster.icp:8500
                BUILD_NUMBER=latest

                docker build -t \${REGISTRY}/\${NAMESPACE}/hello-container:${env.BUILD_NUMBER} .
                """
            } 
            stage('Push Docker Image to Registry') {
                sh """
                #!/bin/bash
                #NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                #REGISTRY=`cat /var/run/configs/registry-config/registry`
                NAMESPACE=default
                REGISTRY=mycluster.icp:8500
                BUILD_NUMBER=latest
                DOCKER_USER=admin
                DOCKER_PASSWORD=admin

                set +x
                DOCKER_USER=`cat /var/run/secrets/registry-account/username`
                DOCKER_PASSWORD=`cat /var/run/secrets/registry-account/password`
                docker login -u=\${DOCKER_USER} -p=\${DOCKER_PASSWORD} \${REGISTRY}
                set -x

                docker push \${REGISTRY}/\${NAMESPACE}/hello-container:${env.BUILD_NUMBER}
                """
            }
        }
        container('containertest') {
            stage('Test built docker Image') {
                sh """
                #!/bin/bash
                #NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                #REGISTRY=`cat /var/run/configs/registry-config/registry`
                NAMESPACE=default
                REGISTRY=mycluster.icp:8500
                container-structure-test  -test.v   -image \${REGISTRY}/\${NAMESPACE}/hello-container:${env.BUILD_NUMBER} /var/tmp/hello-container-test.yaml
                """
            }
        }
        container('helm') {
            stage('Deploy new helm release') {
                sh """
                #!/bin/bash
                set +e
                #NAMESPACE=`cat /var/run/configs/registry-config/namespace`
                #REGISTRY=`cat /var/run/configs/registry-config/registry`
                NAMESPACE=default
                REGISTRY=mycluster.icp:8500
                #CHARTNAME=`helm list --deployed --short hello-container`
                CHARTNAME=hello-container`

                helm list \${CHARTNAME}

                if [ \${?} -ne "0" ]; then
                    # No chart release to update
                    echo 'No chart release to update - installig for the first time'
                   helm install ./hellocontainer-chart/ -n hellocontainer --tls
                else
                   # Update Release 
                   helm upgrade hello-container ./hellocontainer-chart/ --set image.repository=\${REGISTRY}/\${NAMESPACE}/hello-container --set image.tag=${env.BUILD_NUMBER} -n hellocontainer --tls
                fi

                """
            }
        }


    }
}
