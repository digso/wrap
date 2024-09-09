package spider

import (
	"net/http"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

// Based on rule dom structure on the official site,
// which all rules are inside such query:
//
//	"body > main#page-content > article > div.content > p"
//
// Each rule dom is parsed by the function parseRule.
func ParseOfficialAPIs(url string) ([]LintRule, error) {
	response, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer response.Body.Close()

	document, err := goquery.NewDocumentFromReader(response.Body)
	if err != nil {
		return nil, err
	}

	const query = "body > main#page-content > article > div.content > p"
	handler := []LintRule{}
	document.Find(query).Each(func(_ int, selection *goquery.Selection) {
		rule := parseRule(selection)
		if rule != nil {
			handler = append(handler, *rule)
		}
	})
	return handler, nil
}

// Parse Dart lint API rules from such http structure:
//
//	<p>
//		<a href="/tools/linter-rules/rule_name">
//			<code>rule_name</code>
//		</a>
//		<em>(Name)</em>
//		<br>
//		<a href="/tools/linter-rules#tag-area_title">
//			<img src="/assets/img/tools/linter/tag-name.svg" alt="xxx" />
//		</a>
//	</p>
func parseRule(selection *goquery.Selection) *LintRule {
	var rule *LintRule = nil
	selection.Children().Each(func(_ int, selection *goquery.Selection) {
		if rule == nil {
			name := parseName(selection)
			if name != "" {
				rule = &LintRule{Name: name}
			}
		} else {
			ParseTags(selection, rule)
			ParseStatus(selection, rule)
		}
	})
	return rule
}

// Parse name from such dom structure:
//
//	<a href="/tools/linter-rules/rule_name">
//		<code>rule_name</code>
//	</a>
func parseName(selection *goquery.Selection) string {
	if goquery.NodeName(selection) == "a" {
		href, exist := selection.Attr("href")
		const prefix = "/tools/linter-rules/"
		if exist && strings.HasPrefix(href, prefix) {
			name := strings.TrimPrefix(href, prefix)
			child := selection.Children().First()
			if goquery.NodeName(child) == "code" && child.Text() == name {
				return name
			}
		}
	}
	return ""
}

// Parse tag from such dom structure,
// and update into the given rule struct with its pointer:
//
//	<a href="/tools/linter-rules#tag-area_title">
//		<img src="/assets/img/tools/linter/tag-name.svg" alt="xxx" />
//	</a>
func ParseTags(selection *goquery.Selection, rule *LintRule) {
	if goquery.NodeName(selection) != "a" {
		return
	}
	href, exist := selection.Attr("href")
	if !exist || !strings.HasPrefix(href, "/tools/linter-rules#") {
		return
	}

	child := selection.Children().First()
	if goquery.NodeName(child) != "img" {
		return
	}
	src, exist := child.Attr("src")
	const prefix = "/assets/img/tools/linter/"
	if !exist || !strings.HasPrefix(src, prefix) {
		return
	}
	fileName := strings.TrimLeft(src, strings.TrimSpace(prefix))
	fileName = strings.TrimSuffix(fileName, ".svg")
	switch fileName {
	case "has-fix":
		rule.HasFix = true
	case "style-core": // todo fix bug here cannot parse.
		rule.Core = true
	case "style-flutter": // todo fix bug here cannot parse.
		rule.Flutter = true
	case "style-recommended": // todo fix bug here cannot parse.
		rule.Recommended = true
	}
}

// Parse status from such dom structure,
// and return one of the predefined status string:
//
//	<em>(Name)</em>
//
// There will be only zero or one status marked on a single rule.
func ParseStatus(selection *goquery.Selection, rule *LintRule) {
	if goquery.NodeName(selection) == "em" {
		content := strings.ToLower(selection.Text())
		content = strings.TrimFunc(content, func(r rune) bool {
			return r == '(' || r == ')'
		})
		for _, status := range allStatus {
			if content == string(status) {
				rule.Status = status
				break
			}
		}
	}
}
