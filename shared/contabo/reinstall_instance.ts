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

    instances.data.forEach((instance) => {
        console.log(instance.instanceId)
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