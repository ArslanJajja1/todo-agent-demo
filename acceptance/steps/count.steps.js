import assert from 'node:assert/strict';
import { Then } from '@cucumber/cucumber';

Then('I see {string}', function (label) {
  assert.equal(this.list.countLabel(), label);
});
