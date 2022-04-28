[
    {
        "name": "codebeamer-app",
        "hostName": "codebeamer-app",
        "cpu": ${CbCPU},
        "memoryReservation": ${CbMemory},
        "image": "${CbImage}",
        "repositoryCredentials": {
            "credentialsParameter": "${CredentialsParameter}"
        },
        "essential": true,
        "command": ["/home/appuser/utils/update_resources.sh"],
        "environment": ${CbEnvironment},
        "portMappings": [
            {
                "containerPort": 7896,
                "hostPort": 7896
            },
            {
                "containerPort": 8090,
                "hostPort": 443
            },
            {
                "containerPort": 8080,
                "hostPort": 80
            },
            {
                "containerPort": 9998,
                "hostPort": 9998
            },
            {
                "containerPort": 8998,
                "hostPort": 8998
            },
            {
                "containerPort": 9000,
                "hostPort": 9000
            },
            {
                "containerPort": 4001,
                "hostPort": 4001
            },
            {
                "containerPort": 4002,
                "hostPort": 4002
            }
        ],
        "mountPoints": [
            {
                "sourceVolume": "codebeamer-app-repository-access",
                "containerPath": "/home/appuser/codebeamer/repository/access"
            },
            {
                "sourceVolume": "codebeamer-app-repository-docs",
                "containerPath": "/home/appuser/codebeamer/repository/docs"
            },
            {
                "sourceVolume": "codebeamer-app-repository-git",
                "containerPath": "/home/appuser/codebeamer/repository/git"
            },
            {
                "sourceVolume": "codebeamer-app-repository-hg",
                "containerPath": "/home/appuser/codebeamer/repository/hg"
            },
            {
                "sourceVolume": "codebeamer-app-logs",
                "containerPath": "/home/appuser/codebeamer/logs"
            },
            {
                "sourceVolume": "codebeamer-app-repository-lucene",
                "containerPath": "/home/appuser/codebeamer/repository/lucene"
            },
            {
                "sourceVolume": "codebeamer-app-repository-plugins",
                "containerPath": "/home/appuser/codebeamer/repository/plugins"
            },
            {
                "sourceVolume": "codebeamer-app-repository-search",
                "containerPath": "/home/appuser/codebeamer/repository/search"
            },
            {
                "sourceVolume": "codebeamer-app-repository-svn",
                "containerPath": "/home/appuser/codebeamer/repository/svn"
            },
            {
                "sourceVolume": "codebeamer-app-repository-tmp",
                "containerPath": "/home/appuser/codebeamer/repository/tmp"
            },
            {
                "sourceVolume": "codebeamer-app-repository-logo",
                "containerPath": "/home/appuser/codebeamer/repository/logo"
            },
            {
                "sourceVolume": "codebeamer-app-repository-logo",
                "containerPath": "/home/appuser/codebeamer/repository/config/logo"
            },
            {
                "sourceVolume": "codebeamer-app-repository-scmloop",
                "containerPath": "/home/appuser/codebeamer/repository/scmloop"
            },
            {
                "sourceVolume": "utils",
                "containerPath": "/home/appuser/utils"
            }
        ]
    }
]
