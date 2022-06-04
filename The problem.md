The big issue is that we cannot establish a socket connection between two clients with all ports closed (The default on most routers). There are a few potential solutions to this.

# Techniques other P2P apps use
* uPNP
* TCP hole punching

# Fractured TCP requests
Have the clients initially connect through a "third friend", in this case Charlie. (This is a purley theoretical thing that I just thought up once, it has in no way been tested and is probably not possible with modern firewalls)
```
.-----.                      .---.    .-------.
|Alice|                      |Bob|    |Charlie|
'-----'                      '---'    '-------'
   |                           |          |    
   |Connection request [packet]|          |    
   |-------------------------->|          |    
   |                           |          |    
   |              SNY number   |          |    
   |------------------------------------->|    
   |                           |          |    
   |                           |SNY number|    
   |                           |<---------|    
   |                           |          |    
   | Request response [packet] |          |    
   |<--------------------------|          |    
.-----.                      .---.    .-------.
|Alice|                      |Bob|    |Charlie|
'-----'                      '---'    '-------'

```
<!---
Alice -> Bob: Connection request [packet]
Alice -> Charlie: SNY number
Bob <- Charlie: SNY number
Alice <- Bob: Request response [packet]
-->

# Combination
Something like:

1. Direct connection in case any of them have open ports
2. Some of the techniques above
3. Route through other voluntary peers
