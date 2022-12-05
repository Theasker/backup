# Backups with Borg backup

Script made with borg backup.

## Requirements

1. Borg backup intalled
2. config file in json format with a structure like:
```json
{
	"config": {
		"target": "$PWD/backups",
		"repository": "ssh://root@podereuropeo.duckdns.org:22/home/ubuntu/borgbackups",
		"sshfsmount": "/mnt/sshfs"
	},
	"backups": [
		{
			"domain": "domain1.es",
			"port": "22",
			"folders": [
				"/home/ubuntu/.ssh",
				"/root/.ssh"
			]
		},
		{
			"domain": "domain2.org",
			"port": "22",
			"folders": [
				"/home/ubuntu/.ssh",
				"/root/.ssh"
			]
		}
	]
`
```
3. sshfs intalled for mount external domains

