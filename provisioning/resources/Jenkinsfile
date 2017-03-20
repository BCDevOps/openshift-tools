node('master') {
  stage('build') {
         echo "Building..."

         openshiftBuild apiURL: '', authToken: '', bldCfg: 'assets', buildName: '', checkForTriggeredDeployments: 'false', commitID: '', namespace: '', showBuildLogs: 'true', verbose: 'false', waitTime: '', waitUnit: 'sec'
  }
  stage('validate') {
      echo "Testing..."
  }
}
stage('approve') {
    input "Deploy to prod?"
}
node('master') {
    stage('deploy') {
        echo "Deploying..."
    }
}
