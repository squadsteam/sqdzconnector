const io = require('../../../../libs/socket.io.min')
const routesController = new (require('./routesController'))();
const ActionsTransfer = require('../transfer/actionsTransfer');

class SocketController {
    static socket = null;
    static startup(url, key, fxserver_type, version) {
        SocketController.startup_exec_timestamp = new Date();
        const socket = io(url, {
            auth: {
                token: 'FXServer ' + key,
                fxserverType: fxserver_type,
                connectorVersion: version,
                transports: ["websocket"]
            },

            'reconnectionDelay': 30000,
            'reconnectionAttempts': 15
        });

        SocketController.socket = socket;
        this.handler(socket)
    }

    static handler(socket) {
        socket.on('connect_error', (e) => {
            console.log('\x1b[31m' + '[Socket] There was an error while connecting to Node, error : ' + e.message + '\x1b[0m')
        })

        socket.on("connect", () => {
            console.log('\x1b[32m' + '[Socket] Connector has been connected successfully to node. ' + (SocketController.startup_exec_timestamp != null ? '(' + ((new Date()) - SocketController.startup_exec_timestamp) + 'ms)' : '') + '\x1b[0m')
            SocketController.startup_exec_timestamp = null;
        });

        socket.on("disconnect", (e) => {
            console.log('\x1b[31m' + '[Socket] Connector has been disconnected from node. reason : ' + e + '\x1b[0m')
        });

        socket.on("connector_up", (connector_id) => {
            console.log('[Socket] Node accepted connection, requests are ready now!\nConnector ID: ' + '\x1b[36m' + connector_id + '\x1b[0m')
        })

        socket.on("packet_out", function (data) {
            if (data.packetId != null) {
                (async () => {
                    await routesController.execute(socket, data.packetId, data);
                })();
            }
        });

        socket.on("execute_actions", function (data) {
            if (data.data != null) {
                ActionsTransfer.transfer(data.data);
            }
        });
    }

    static getSocket() {
        return SocketController.socket;
    }
}

module.exports = SocketController;