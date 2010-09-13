/*
 * Asterisk -- An open source telephony toolkit.
 *
 * Copyright (C) 2005 - 2006, Digium, Inc.
 * Copyright (C) 2005, Claude Patry
 * Copyright (C) 2010, Chase Venters
 *
 * See http://www.asterisk.org for more information about
 * the Asterisk project. Please do not directly contact
 * any of the maintainers of this project for assistance;
 * the project provides a web site, mailing lists and IRC
 * channels for your use.
 *
 * This program is free software, distributed under the terms of
 * the GNU General Public License Version 2. See the LICENSE file
 * at the top of the source tree.
 */

/*! \file
 *
 * \brief Does a DNS lookup
 * 
 */

#include "asterisk.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#include "asterisk/module.h"
#include "asterisk/channel.h"
#include "asterisk/pbx.h"
#include "asterisk/logger.h"
#include "asterisk/utils.h"
#include "asterisk/app.h"

static int dns_lookup(struct ast_channel *chan, char *cmd, char *data,
			 char *buf, size_t len)
{
	unsigned int ip_len, bytes_used = 0;
	struct in_addr inaddr;
	struct ast_hostent ahe;
	struct hostent *hp;
	const char *ip;
	char **aptr;

	if (ast_strlen_zero(data)) {
		ast_log(LOG_WARNING, "Syntax: DNS(<data>) - missing argument!\n");
		return -1;
	}

	/* look up host */
	hp = ast_gethostbyname(data, &ahe);
	if (hp == 0) {
		*buf = 0;
		return 0;
	}

	/* add results to return buffer */
	aptr = hp->h_addr_list;
	while (*aptr != 0) {
		/* get this ip */
		memcpy(&inaddr, *aptr, sizeof(inaddr));	
		ip = ast_inet_ntoa(inaddr);
		ip_len = strlen(ip);

		/* make sure we have space for this ip */
		if (bytes_used + 2 + ip_len > len) {
			break;	
		}

		/* add separator */
		if (bytes_used > 0) {
			*buf++ = ',';
			bytes_used++;
		}

		/* write ip into buf */
		memcpy(buf, ip, ip_len);
		buf += ip_len;
		bytes_used += ip_len;
		aptr++;
	}

	/* null-terminate return buffer */
	*buf = 0;

	return 0;
}

static struct ast_custom_function dns_function = {
	.name = "DNS",
	.synopsis = "Does a DNS lookup",
	.desc = "Returns the IP addresses, separated by a ,\n",
	.syntax = "DNS(<string>)",
	.read = dns_lookup,
};

static int unload_module(void)
{
	return ast_custom_function_unregister(&dns_function);
}

static int load_module(void)
{
	return ast_custom_function_register(&dns_function);
}

#define AST_MODULE "DNS"
AST_MODULE_INFO_STANDARD(ASTERISK_GPL_KEY, "dns lookup function");
#undef AST_MODULE

