#!/bin/sh

test_description="request generated html pages"

. /usr/share/sharness/sharness.sh


get_munin_url() {
    # "--no-buffer" prevents curl errors ("(23) Failed writing body") in case of incomplete consumption (e.g. "grep -q")
    curl --silent --fail --no-buffer "http://localhost:4948/${1#/}"
}


assert_mime_type() {
    echo "$1" >expected_mime_type
    file --mime-type --brief - >received_mime_type
    test_cmp expected_mime_type received_mime_type
}


assert_http_response_content() {
    local url="$1"
    local expected_content="$2"
    get_munin_url "$url" | grep -qF "$expected_content"
}


test_expect_success "main site: mime type" '
  get_munin_url "/" | assert_mime_type "text/html"
'

test_expect_success "main site: dynamically generated" '
  assert_http_response_content "/" "Auto-generated by Munin"
'

test_expect_success "main site: contains node" '
  assert_http_response_content "/" "example.com/"
'

test_expect_success "assets: CSS" '
  assert_http_response_content "/static/css/style.css" "margin"
'

test_expect_success "node: html" '
  assert_http_response_content "/example.com/munin.example.com/" "memory-day.png"
'

test_expect_success "node: graph as png" '
  get_munin_url "/example.com/munin.example.com/memory-day.png" | assert_mime_type "image/png"
'

test_expect_success "node: graph as svg" '
  get_munin_url "/example.com/munin.example.com/memory-day.svg" | assert_mime_type "image/svg+xml"
'

test_done