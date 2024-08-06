'use strict';
'require view';
'require form';

return view.extend({
	render: function() {
		var m, s, o;
		m = new form.Map('koti', _('Koti'));

		s = m.section(form.TypedSection, 'dns', _('DNS'));
		s.anonymous = true;

		o = s.option(form.Flag, 'enable', _('Redirect DNS'));
		o.default = '1';
		o.rmempty = false;

		s = m.section(form.TypedSection, 'dnssec', _('DNSSEC'));
		s.anonymous = true;
		o = s.option(form.Flag, 'enable', _('Enable'));
		o.default = '1';
		o.rmempty = false;

		s = m.section(form.TypedSection, 'dot', _('DoT'));
		s.anonymous = true;
		o = s.option(form.Flag, 'enable', _('Enable'));
		o.default = '1';
		o.rmempty = false;
		o = s.option(form.MultiValue, 'zone', _('Provider'));
		o.value('fwd_quad9_dns', 'Quad9 (filters, DNSSEC, no ECS)');
		o.value('fwd_quad9_dns11', 'Quad9 (filters, DNSSEC, ECS)');
		o.value('fwd_google', 'Google');
		o.value('fwd_cloudflare', 'Cloudflare');
		o.rmempty = false;
		o.editable = false;

		return m.render();
	},
});
