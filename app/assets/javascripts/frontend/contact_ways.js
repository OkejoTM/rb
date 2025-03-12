function contactWays(scope = '') {
  const contact_ways = ['viber', 'telegram', 'whatsapp'];

  return _.reduce(contact_ways, function (result, contact_way) {
    let checkbox = $(`#${scope}contact_way_${contact_way}`);

    if(checkbox.prop('checked')) {
      result.push({
        way_type: checkbox.val()
      });
    }

    return result
  }, []);
}

export { contactWays }
