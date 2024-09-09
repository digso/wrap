package main

import (
	"fmt"

	"github.com/digso/wrap/strict-lints/spider"
)

func main() {
	// Parse official docs.
	const url = "https://dart.dev/tools/linter-rules"
	rules, err := spider.ParseOfficialAPIs(url)
	if err != nil {
		fmt.Errorf("failed to parse lint rules from %s: %v", url, err)
		return
	}

	for i, v := range rules {
		fmt.Println(i, v.String())
	}
}
