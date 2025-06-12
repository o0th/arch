; Inject JSON into block scalar where key ends in `.json`
(
  (block_mapping_pair
    key: (flow_node
      (plain_scalar
        (string_scalar) @json_key))
    value: (block_node
      (block_scalar) @json_content)
    (#match? @json_key ".*\\.json")
  )
  (#set! injection.language "json")
)
