[
    {
        "name": "healthcheck",
        "cpu": 128,
        "memoryReservation": 64,
        "image": "${Image}",
        "repositoryCredentials": {
            "credentialsParameter": "${CredentialsParameter}"
        },
        "essential": true,
        "environment": ${Environment}
    }
]