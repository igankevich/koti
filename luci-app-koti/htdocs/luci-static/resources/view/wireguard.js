'use strict'
'require form'
'require rpc'
'require view'

const rpcs = {
    newServer: rpc.declare({
        object: 'luci.koti',
        method: 'wgNewServer',
        params: ['name', 'ipaddr'],
    }),
}

async function newServer() {
    const ret = await rpcs.newServer('hello', '10.79.111.0/24')
    console.log(ret)
}

return view.extend({
    generic_failure: function (message) {
        // Map an error message into a div for rendering
        return E(
            'div',
            {
                class: 'error',
            },
            [_('RPC call failure: '), message],
        )
    },
    load: function () {
        return Promise.all([])
    },
    render: function (data) {
        return E('div', {}, [
            E(
                'button',
                {
                    class: 'btn',
                    click: newServer,
                },
                [_('New server')],
            ),
        ])
    },
    handleSave: null,
    handleSaveApply: null,
    handleReset: null,
})
