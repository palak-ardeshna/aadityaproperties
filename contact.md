---
title: Contact
description: How to contact Aaditya Properties, report an error or ask a question about a guide.
permalink: /contact/
ads: false
---
# Contact

{% if site.contact_email != "" %}
- **Email:** [{{ site.contact_email }}](mailto:{{ site.contact_email }})
{% if site.contact_phone != "" %}- **Phone:** {{ site.contact_phone }}{% endif %}
{% if site.operator_city != "" %}- **Based in:** {{ site.operator_city }}{% endif %}

We aim to reply within two working days.
{% else %}
Our contact email is being set up and will appear here shortly.
{% endif %}

## Reporting an error
If you think something in a guide is wrong or out of date, tell us which page and which statement, and if possible link to the official source. We follow our [corrections policy]({{ '/corrections/' | relative_url }}).

## What we can't help with
We can't give personal legal, tax or investment advice, value a property, or check documents for a specific transaction. Please consult a qualified professional for those.
