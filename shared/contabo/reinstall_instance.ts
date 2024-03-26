import { randomUUID } from 'crypto';
import { env } from './env';
async function reinstallInstance() {

    const result = await fetch('https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: 'client_id=' + env.CLIENT_ID + '&client_secret=' + env.CLIENT_SECRET + '&username=' + env.API_USER + '&password=' + env.API_PASSWORD + '&grant_type=password'
    });

    const data = await result.json();

    const ACCESS_TOKEN = data.access_token;

    const listingInstances =
        await fetch('https://api.contabo.com/v1/compute/instances', {
            headers: {
                'Authorization': `Bearer ${ACCESS_TOKEN}`,
                'x-request-id': '51A87ECD-754E-4104-9C54-D01AD0F83406'
            }
        });

    const instances = await listingInstances.json();


    // FIXME: This is not working
    instances.data.forEach(async (instance) => {
        const uuid = randomUUID()

        const instanceId = instance.instanceId

        // console.log("instanceId: ", instanceId)

        const response = await fetch(`https://api.contabo.com/v1/compute/instances/${instanceId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${ACCESS_TOKEN}`,
                'x-request-id': uuid,
                'x-trace-id': 'reinstall-all'
            },
            // body: '{"imageId": "a2c26e8f-84a5-4f3e-9c0e-b06511928cc0", "sshKeys": [1,2], "rootPassword": 12}',
            body: JSON.stringify({
                'imageId': '4efbc0ba-2313-4fe1-842a-516f8652e729',
                'sshKeys': [
                    env.SSH_KEY
                ],
                'rootPassword': env.ROOT_PASSWORD
            })
        })
        const data = await response.json()
        console.log("response:", data)


        // console.log(instance)
    })

    return listingInstances


}

reinstallInstance().then((data) => { console.log("instance shown above") })

// 201756551
// 201731300
// 201756509
// 201756556
// 201516676
// 201529204

// Debian 12 id = 4efbc0ba-2313-4fe1-842a-516f8652e729
// Ubuntu 23 id = 84b3b568-d7c9-48a4-9c07-2e328598caec