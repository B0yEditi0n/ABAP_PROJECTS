import express, { request, response } from 'express';
import bodyParser from 'body-parser';
import { HttpApiConnect } from './function/getRequest.js';


const http = 'https://dh-consulting-sap-api-default-rtdb.firebaseio.com/DHCONSULTING';
const app = express();
const PORT = 5723;
const extension = true;

var apiConnect = new HttpApiConnect;

app.use(bodyParser.json());
app.listen(PORT, () => console.log(`Servidor rodando em \nhttp://localhost:${PORT}/`));

/*
 * Rencaminhar o GET
 */

app.get('/*', async (request, response) => {
    console.log('\nRequisição de:', request.headers['user-agent']);
    console.log('Get');
    var formatedJson = await apiConnect.getJson(`${http}${request.path}`, extension);
    console.log('Retornando Resposta para SAP');
    
    // Variaveis Indivudais não podem ser retornadas no formato Objeto;
    if(typeof formatedJson == 'object'){
        response.json(formatedJson);
    }else if (typeof formatedJson == null || typeof formatedJson == undefined){
        response.send(formatedJson.toString());
    }
    else{
        response.send(formatedJson.toString());
    }
    
});

/*
 * Rencaminhar o Post
*/

app.post('/*', async (request, response) =>{
    console.log('\nPost');
    console.log('Request:', request.body);
    console.log('Resposta:', response.params);
    console.log('Caminho', request.path);

    var responsePOST = await apiConnect.postJson(`${http}${request.path}`, extension, request.body);
    response.json( await responsePOST );
});

/*
 * Rencaminhar o Delete
*/

app.delete('/*', async(request, response)=>{
    console.log('\nRequisição de:', request.headers['user-agent']);
    console.log('Pedido de DELETE');
    var responseDELETE = await apiConnect.deleteJson(`${http}${request.path}`, extension);
    response.json( await responseDELETE );
})

/*
 * Rencaminhar o Delete
*/

app.put('/*', async(request, response)=>{
    console.log('\nRequisição de:', request.headers['user-agent']);
    console.log('Pedido de PUT')
    var responsePUT = await apiConnect.putJson(`${http}${request.path}`, extension, request.body);
    response.json( await responsePUT );   
})