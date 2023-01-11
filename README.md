# Burp Interactor

## Usage

1. Open Burp Suite Professional.
2. Open Burp Collaborator Client tool.
3. Get a &lt;BURPCOLLABORATOR-HOSTNAME-1&gt; and URL decoded &lt;BIID-1&gt; for external to internal communication.
4. Get a &lt;BURPCOLLABORATOR-HOSTNAME-2&gt; and URL decoded &lt;BIID-2&gt; for internal to external communication.
5. Execute the python server script on the external computer.

```
sh > python3 bi-server.py <BURPCOLLABORATOR-HOSTNAME-1> <BIID-2> S3cr3tK3y
```

5. Execute the client powershell script on the internal computer.

```
PS > .\bi-client.ps1 <BURPCOLLABORATOR-HOSTNAME-2> <BIID-1> S3cr3tK3y
```
```
PS > .\bi-client.ps1 <BURPCOLLABORATOR-HOSTNAME-2> <BIID-1>
Enter Key: S3cr3tK3y
```
