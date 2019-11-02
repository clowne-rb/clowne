# Supported Adapters

Clowne supports the following ORM adapters (and associations):

Adapter                                            |1:1         | 1:M         | M:M                     |
---------------------------------------------------|------------|-------------|-------------------------|
[:active_record](active_record)         | has_one    | has_many    | has_and_belongs_to_many |
[:sequel](sequel)                       | one_to_one | one_to_many | many_to_many            |

For more information see the corresponding adapter documentation.
