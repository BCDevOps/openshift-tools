### Running OWASP ZAP in the pipeline

The simplest way of running ZAP in the pipeline is to include the following code in you pipeline Jenkinsfile:

```
podTemplate(label: 'owasp-zap', name: 'owasp-zap', serviceAccount: 'jenkins', cloud: 'openshift', containers: [
  containerTemplate(
    name: 'jnlp',
    image: '172.50.0.2:5000/openshift/jenkins-slave-zap',
    resourceRequestCpu: '500m',
    resourceLimitCpu: '1000m',
    resourceRequestMemory: '3Gi',
    resourceLimitMemory: '4Gi',
    workingDir: '/home/jenkins',
    command: '',
    args: '${computer.jnlpmac} ${computer.name}'
  )
]) {
  stage('ZAP Security Scan') {
    node('zap') {
        //the checkout is mandatory
        echo "checking out source"
        echo "Build: ${BUILD_ID}"
        checkout scm
        dir('zap') {
            def retVal = sh returnStatus: true, script: './runzap.sh'
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: true, reportDir: '/zap/wrk', reportFiles: 'index.html', reportName: 'ZAP Full Scan', reportTitles: 'ZAP Full Scan'])
            echo "Return value is: ${retVal}"
            }
    }
  }
}
```
