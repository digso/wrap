package spider

import "strings"

type Status string

const (
	STATUS_EXPERIMENTAL Status = "experimental"
	STATUS_DEPRECATED   Status = "deprecated"
	STATUS_REMOVED      Status = "removed"
)

var allStatus = []Status{
	STATUS_EXPERIMENTAL,
	STATUS_DEPRECATED,
	STATUS_REMOVED,
}

// 根据 https://dart.dev/tools/linter-rules 中的结构定义。
type LintRule struct {
	Name        string
	Status      Status
	HasFix      bool
	Core        bool
	Flutter     bool
	Recommended bool
}

func (rule *LintRule) String() string {
	tags := []string{}
	if rule.Status != "" {
		tags = append(tags, string(rule.Status))
	}
	if rule.HasFix {
		tags = append(tags, "fix")
	}
	if rule.Core {
		tags = append(tags, "core")
	}
	if rule.Flutter {
		tags = append(tags, "flutter")
	}
	if rule.Recommended {
		tags = append(tags, "recommended")
	}
	return rule.Name + "(" + strings.Join(tags, ",") + ")"
}
