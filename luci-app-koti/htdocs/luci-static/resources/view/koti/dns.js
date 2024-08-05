'use strict';
'require view';
'require form';

return view.extend({
	render: function() {
		var m, s, o;
		m = new form.Map('koti', _('DNS'), _('DNS Configuration.'));

		s = m.section(form.TypedSection, 'dns', _('DNS'));
		s.anonymous = true;

		o = s.option(form.Flag, 'enable', _('Redirect DNS'));
		o.default = '1';
		o.rmempty = false;

		s = m.section(form.TypedSection, 'dnssec', _('DNSSEC'));
		s.anonymous = true;
		o = s.option(form.Flag, 'enable', _('Enable DNSSEC'));
		o.default = '1';
		o.rmempty = false;

		return m.render();
	},
});
