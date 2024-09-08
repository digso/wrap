package spider_test

import (
	"testing"

	"github.com/digso/wrap/strict-lints/spider"
)

func TestRuleFmt(t *testing.T) {
	rule := spider.LintRule{
		Name: "test_rule",
	}
	const result = "test_rule()"
	if rule.String() != result {
		t.Errorf("Expected %s, got %s", result, rule.String())
	}
}
