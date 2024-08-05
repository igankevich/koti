'use strict';
'require view';
'require form';

return view.extend({
	render: function() {
		var m, s, o;
		m = new form.Map('koti', _('DNS'), _('DNS Configuration.'));

		s = m.section(form.TypedSection, 'dns', _('DNS'));
		s.anonymous = true;

		o = s.option(form.Flag, 'enable', _('Enable DoT'),
			_('Enable DNS over TLS.'));
		o.default = '1';
		o.rmempty = false;

		return m.render();
	},
});
