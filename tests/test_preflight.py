import importlib.util
from pathlib import Path
import tempfile
import unittest

SCRIPT=Path(__file__).resolve().parents[1]/'scripts/check_system.py'
spec=importlib.util.spec_from_file_location('preflight',SCRIPT)
preflight=importlib.util.module_from_spec(spec)
spec.loader.exec_module(preflight)

class PreflightTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        self.write('sys/class/dmi/id/product_name',preflight.MODEL)
        self.write('sys/class/dmi/id/bios_version',preflight.BIOS)
        self.write('sys/devices/platform/msi-ec/fw_version',preflight.EC)
        self.write('lib/modules/test/build/include/acpi/battery.h','void acpi_battery_hook_register(struct acpi_battery_hook *hook);')
    def write(self,path,text):
        p=self.root/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)
    def inspect(self,**kw):return preflight.inspect(self.root,kernel='test',**kw)
    def test_exact_match(self):
        r=self.inspect();self.assertTrue(r['matches_tested_configuration']);self.assertEqual(r['battery_api'],'modern')
    def test_model_mismatch(self):
        self.write('sys/class/dmi/id/product_name','Different MSI')
        self.assertFalse(self.inspect()['matches_tested_configuration'])
    def test_bios_mismatch(self):
        self.write('sys/class/dmi/id/bios_version','E16R8IMS.999')
        self.assertFalse(self.inspect()['matches_tested_configuration'])
    def test_ec_mismatch_cannot_be_overridden(self):
        self.write('sys/devices/platform/msi-ec/fw_version','16R8IMS1.111')
        self.assertFalse(self.inspect(confirmed_ec=preflight.EC)['matches_tested_configuration'])
    def test_missing_ec_needs_confirmation(self):
        (self.root/'sys/devices/platform/msi-ec/fw_version').unlink()
        self.assertFalse(self.inspect()['matches_tested_configuration'])
        r=self.inspect(confirmed_ec=preflight.EC)
        self.assertTrue(r['matches_tested_configuration']);self.assertTrue(r['ec_manually_confirmed'])
    def test_confirmation_does_not_bypass_model(self):
        (self.root/'sys/devices/platform/msi-ec/fw_version').unlink()
        self.write('sys/class/dmi/id/product_name','Other laptop')
        self.assertFalse(self.inspect(confirmed_ec=preflight.EC)['matches_tested_configuration'])
    def test_missing_headers(self):
        (self.root/'lib/modules/test/build/include/acpi/battery.h').unlink()
        self.assertFalse(self.inspect()['matches_tested_configuration'])
    def test_legacy_headers(self):
        self.write('lib/modules/test/build/include/acpi/battery.h','void battery_hook_register(struct acpi_battery_hook *hook);')
        r=self.inspect();self.assertEqual(r['battery_api'],'legacy');self.assertTrue(r['matches_tested_configuration'])
    def test_unrelated_name_does_not_count(self):
        self.write('lib/modules/test/build/include/acpi/battery.h','void devm_acpi_battery_hook_register(void);')
        self.assertFalse(self.inspect()['matches_tested_configuration'])

if __name__=='__main__':unittest.main()
