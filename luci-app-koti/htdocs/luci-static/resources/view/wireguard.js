'use strict';
'require form';
'require rpc';
'require view';

if (document.getElementById('koti-bundle') == null) {
    var script = document.createElement('script');
    script.onload = function () {
        window.qrcode = require('qrcode');
    };
    script.src = '/luci-static/resources/bundle.js';
    script.id = 'koti-bundle';
    document.body.appendChild(script);
}

const rpcs = {
    newServer: rpc.declare({
        object: 'luci.koti',
        method: 'wgNewServer',
    }),
    newClient: rpc.declare({
        object: 'luci.koti',
        method: 'wgNewClient',
    }),
    dump: rpc.declare({
        object: 'luci.koti',
        method: 'wgDump',
    }),
};

async function newServer() {
    await rpcs.newServer();
    await updateWireguardNodes();
}

async function newClient() {
    const response = await rpcs.newClient();
    updateClientConfig(response.config);
    await updateQRcode(response.config);
    await updateWireguardNodes();
}

function renderWireguardNodes(nodes) {
    const rows = [];
    if (nodes.length !== 0) {
        rows.push(
            E('tr', { class: 'tr' }, [
                E('th', { class: 'th' }, ['Public key']),
                E('th', { class: 'th' }, ['IP']),
                E('th', { class: 'th' }, ['Latest handshake']),
                E('th', { class: 'th' }, ['Rx']),
                E('th', { class: 'th' }, ['Tx']),
            ]),
        );
        for (const node of nodes) {
            const allowedIps =
                node.allowedIps && node.allowedIps.endsWith('/32')
                    ? node.allowedIps.substring(0, node.allowedIps.length - 3)
                    : node.allowedIps;
            rows.push(
                E('tr', { class: 'tr' }, [
                    E('td', { class: 'td' }, [node.publicKey || '']),
                    E('td', { class: 'td' }, [allowedIps || '']),
                    E('td', { class: 'td' }, [node.latestHandshake || '']),
                    E('td', { class: 'td' }, [node.transferRx || '']),
                    E('td', { class: 'td' }, [node.transferTx || '']),
                ]),
            );
        }
    }
    return rows;
}

let wgDumpTimeout = null;
let wgDumpCounter = 0;
let wgNumNodesOld = 0;

async function updateWireguardNodes() {
    if (wgDumpTimeout != null) {
        clearTimeout(wgDumpTimeout);
        wgDumpTimeout = null;
        wgDumpCounter = 0;
    }
    const table = document.getElementById('wgNodes');
    if (table == null) {
        return;
    }
    const data = await rpcs.dump();
    if (data.nodes.length === wgNumNodesOld) {
        wgDumpCounter++;
        if (wgDumpCounter > 10) {
            return;
        }
        wgDumpTimeout = setTimeout(updateWireguardNodes, 999);
        return;
    }
    wgNumNodesOld = data.nodes.length;
    const rows = renderWireguardNodes(data.nodes);
    table.replaceChildren(...rows);
}

function updateClientConfig(config) {
    const wgConfig = document.getElementById('wgConfig');
    if (wgConfig == null) {
        return;
    }
    wgConfig.innerText = config;
}

function updateQRcode(config) {
    const wgQRcode = document.getElementById('wgQRcode');
    if (wgQRcode == null) {
        return;
    }
    qrcode.toString(
        config,
        {
            type: 'svg',
            errorCorrectionLevel: 'H',
        },
        (err, string) => {
            wgQRcode.innerHTML = string;
        },
    );
}

return view.extend({
    load: function () {
        return rpcs.dump();
    },
    render: function (data) {
        const rows = renderWireguardNodes(data.nodes);
        return E('div', {}, [
            E('table', { class: 'table', id: 'wgNodes' }, rows),
            E(
                'button',
                {
                    class: 'btn',
                    click: newServer,
                },
                [_('New server')],
            ),
            E(
                'button',
                {
                    class: 'btn',
                    click: newClient,
                },
                [_('New client')],
            ),
            E('pre', { class: 'pre', id: 'wgConfig' }, []),
            E('div', { id: 'wgQRcode', style: 'max-width: 256px' }, []),
        ]);
    },
    handleSave: null,
    handleSaveApply: null,
    handleReset: null,
});
