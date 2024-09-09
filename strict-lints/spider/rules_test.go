package spider_test

import (
	"testing"

	"github.com/digso/wrap/strict-lints/spider"
)

func TestRuleFmt(t *testing.T) {
	rule := spider.LintRule{
		Name:    "test_rule",
		Status:  spider.STATUS_DEPRECATED,
		HasFix:  true,
		Flutter: true,
	}
	const result = "test_rule(deprecated,fix,flutter)"
	if rule.String() != result {
		t.Errorf("Expected %s, got %s", result, rule.String())
	}
}
