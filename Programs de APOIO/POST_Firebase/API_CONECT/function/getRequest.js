import e from "express";

// Get resquest
export class HttpApiConnect{
    // Parametros
    parametrosIdNota = '';

    defineParameters(Parametros){
        try{
            this.parametrosIdNota = Parametros.id_nota;
            return 0;
        }catch(erro){
            this.parametrosIdNota = '';
            return 0;
        }
        
    }

    defineToken(User_Token, IM){
        this.X_Auth_User_Token = User_Token;
        this.X_Auth_IM         = IM;
        return 0;
    }

    async slowerFetch(url, options){
        try{
            const response = await fetch(url, options);
            // Se tudo certo
            if(response.status == 200 && response.type == 'basic'){
                const jsonData = await response.json();
                return jsonData;            
            }else{
                return response; 
            }

        } catch(erro){
            console.log(erro);

            if (erro = 'ConnectTimeoutError'){
                return('Erro na Conexão com API')
            }
            else{
                
                return('Erro de Conexão com API principal')
            }
        }

    }

    async getJson(http, extensionJson ){
        var urlExtension  = '';

        if(extensionJson){
            urlExtension = '.json';
        }
        
        console.log(`${http}${urlExtension}`);
        console.log('Aguardando Resposta da API...');

        const options = {
            method: 'GET',
            headers: {
                "Content-Type": "application/json",
            }
        }

        var jsonData = await this.slowerFetch(`${http}${urlExtension}`, options);

        console.log('Resposta Recebida');
        return ( jsonData );
    }

    async postJson(http, extensionJson, jsonPOST){
        var urlExtension = '';
        const options = {
            method: "POST",
            headers: { 
                "Content-Type": "application/json",
            },
            body: JSON.stringify(jsonPOST),
        };
        if(extensionJson){
            urlExtension = '.json'
        }

        const response = await this.slowerFetch(`${http}${urlExtension}`, options);

        console.log('Envio para', http);
        console.log('Status do Envio:', response.status);
        
        return response;
    }

    async deleteJson(http, extensionJson){
        var urlExtension = '';
        const options = {
            method: "DELETE",
            headers: { 
                "Content-Type": "application/json",
            }
        };
        if(extensionJson){
            urlExtension = '.json'
        }
        
        const response = await this.slowerFetch(`${http}${urlExtension}`, options);
        console.log('Delete para', http);
        console.log('Status do Envio:', response);

        if (response == null){ // Google não Retorna nada no DELETE
            return 'Deletado';
        }else{
            return response
        }
        
        
    }

    async putJson(http, extensionJson, jsonPUT){
        var urlExtension = '';
        const options = 
        {
            method: "PUT",
            headers: { 
                "Content-Type": "application/json",
            },
            body: JSON.stringify(jsonPUT),
        };
        if(extensionJson){
            urlExtension = '.json'
        }
        
        const response = await this.slowerFetch(`${http}${urlExtension}`, options);
        
        console.log('Alteração para', http);
        console.log('Status do Envio:', response.status);
        return response

    }
}
    